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
    self.catchImageView.contentMode = UIViewContentModeScaleAspectFill;
    if (self.catchInProgress.image) {
        self.catchImageView.image = [self.catchInProgress.image applyLightEffect];
    } else {
        self.catchImageView.image = [[UIImage imageNamed:@"defaultCatchBackground"] applyLightEffect];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"DATA ENTRY WILL APPEAR");
    [super viewWillAppear:animated];
    [self initSpeciesPicker];
    [self initCatchImageView];
    [self initFlyField];
    [self initLocationTracking];
}

- (void)initLocationTracking {
    NSLog(@"start location tracking");
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
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
    NSLog(@"setting catch location to: %@", self.locationManager.location);
    self.catchInProgress.location = self.locationManager.location;
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
