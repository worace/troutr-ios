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

- (void)initCatchImageView {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *imageForBackground = nil;
        if (self.catchInProgress.image) {
            imageForBackground = [self.catchInProgress.image applyLightEffect];
        } else {
            imageForBackground = [[UIImage imageNamed:@"defaultCatchBackground"] applyLightEffect];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            self.catchImageView.contentMode = UIViewContentModeScaleAspectFill;
            self.catchImageView.alpha = 0.0;
            self.catchImageView.image = imageForBackground;
            [UIView animateWithDuration:2.0 animations:^{
                self.catchImageView.alpha = 1.0;
            }];
            NSLog(@"finished setting image");
        });
    });
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSpeciesPicker];
    //TODO -- figure out why image view loads so slow coming out of camera session
    [self initCatchImageView];
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
    NSLog(@"location update");
    NSLog(@"%d", [locations count]);
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
- (void)flyPickerDidSelectFly:(NSString *)fly fromPicker:(UIViewController *)picker {
    self.flyField.text = fly;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)presentFlyPicker {
    TRFlyPickerTableViewController *flyPickerVC = [[TRFlyPickerTableViewController alloc] init];
    flyPickerVC.delegate = self;
    [self presentViewController:flyPickerVC animated:YES completion:nil];
}
@end
