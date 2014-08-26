//
//  TRCatchDataEntryViewController.m
//  troutr-ios
//
//  Created by Horace Williams on 5/13/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "TRCatchDataEntryViewController.h"
#import "TRCatchLog.h"
#import "TRCatchDetailViewController.h"
#import "TRFlyPickerTableViewController.h"
#import "UIImage+ImageEffects.h"
#import "TRFlyStore.h"
#import <AVFoundation/AVFoundation.h>
#import "TRFlyPickerDelegate.h"

@interface TRCatchDataEntryViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, TRFlyPickerDelegate, CLLocationManagerDelegate>
@property (strong, nonatomic) UIPickerView *speciesPicker;
@property (strong, nonatomic) IBOutlet UITextField *speciesField;
@property (weak, nonatomic) IBOutlet UIImageView *catchImageView;
@property (strong, nonatomic) IBOutlet UITextField *flyField;
@property (strong, nonatomic) CLLocationManager *locationManager;
@end

@implementation TRCatchDataEntryViewController

- (void)initSpeciesPicker {
    self.speciesPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 43, 320, 480)];
    self.speciesPicker.delegate = self;
    self.speciesPicker.dataSource = self;
    [self.speciesPicker setShowsSelectionIndicator:YES];
    self.speciesField.inputView = self.speciesPicker;
}

- (void)initFlyField {
    self.flyField.returnKeyType = UIReturnKeyDone;
    self.flyField.enablesReturnKeyAutomatically = NO;
    self.flyField.delegate = self;
}

- (void)initCatchImageViewWithImage:(UIImage *)image {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.catchImageView.contentMode = UIViewContentModeScaleAspectFill;
        self.catchImageView.alpha = 0.0;
        self.catchImageView.image = image;
        [UIView animateWithDuration:0.7 animations:^{
            self.catchImageView.alpha = 1.0;
        }];
    });
}

- (void)playerReachedEnd:(NSNotification *)notification {
    NSLog(@"player reached end");
    AVPlayerItem *playerItem = [notification object];
    if (playerItem) {
        [playerItem seekToTime:kCMTimeZero];
    }
}

- (void)initCatchVideoViewWithURL:(NSURL *)assetURL {
    NSLog(@"init catch video with url: %@", assetURL);
    AVPlayer *player = [AVPlayer playerWithURL:assetURL];
    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerReachedEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[player currentItem]];
    
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.frame;
    [self.view.layer insertSublayer:layer atIndex:0];
    self.view.backgroundColor = [UIColor clearColor];
    [self.view bringSubviewToFront:self.speciesField];

    [player play];
}

- (void)initBackgroundDisplay {
    NSLog(@"init background display; video url is %@", self.catchInProgress.videoAssetURL);
    if (self.catchInProgress.image) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
            [self initCatchImageViewWithImage:[self.catchInProgress.image applyLightEffect]];
        });

    } else if (self.catchInProgress.videoAssetURL) {
        [self initCatchVideoViewWithURL:self.catchInProgress.videoAssetURL];
        
    } else {
        UIImage *defaultImage = [[UIImage imageNamed:@"defaultCatchBackground"] applyLightEffect];
        [self initCatchImageViewWithImage:defaultImage];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSpeciesPicker];
    [self initBackgroundDisplay];
    [self initFlyField];
    [self initLocationTracking];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)initLocationTracking {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        [self.locationManager startUpdatingLocation];
    });
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
     NSLog(@"first location %@", [locations firstObject]);
}

#pragma mark - IBActions
- (IBAction)finishedEnteringData:(UIButton *)sender {
    [self saveCatchInProgress];
    [self.locationManager stopUpdatingLocation];
    TRCatchDetailViewController *detail = [[TRCatchDetailViewController alloc] init];
    detail.catch = self.catchInProgress;
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)saveCatchInProgress {
    self.catchInProgress.species = self.speciesField.text;
    self.catchInProgress.fly = self.flyField.text;
    self.catchInProgress.location = self.locationManager.location;
    self.catchInProgress.dateCreated = [NSDate date];
    [[TRCatchLog sharedStore] recordCatch:self.catchInProgress];
}

#pragma mark - PickerViewDelgate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [[self availableSpecies] objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.speciesField.text = [[self availableSpecies] objectAtIndex:row];
    [self.speciesField endEditing:YES];
}

#pragma mark - PickerViewDataSource

- (NSArray *)availableSpecies {
    return @[@"Brown Trout", @"Brook Trout", @"Rainbow Trout", @"Smallmouth Bass",
             @"Largemouth Bass", @"Bluegill", @"Sunfish"];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (component == 0) {
        return [[self availableSpecies] count];
    } else {
        return 0;
    }
}

#pragma mark - TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.flyField) {
        [self.flyField resignFirstResponder];
        [self presentFlyPicker];
        return NO;
    } else {
        return YES;
    }
}

#pragma  mark - fly picker
- (void)flyPickerDidSelectItem:(NSString *)item fromPicker:(UIViewController *)picker {
    self.flyField.text = item;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentFlyPicker {
    TRFlyPickerTableViewController *flyPickerVC = [[TRFlyPickerTableViewController alloc] init];
    flyPickerVC.delegate = self;
    [self presentViewController:flyPickerVC animated:YES completion:nil];
}
@end
