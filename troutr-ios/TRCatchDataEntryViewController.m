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

@interface TRCatchDataEntryViewController () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate>
@property (strong, nonatomic) UIPickerView *speciesPicker;
@property (strong, nonatomic) IBOutlet UITextField *speciesField;
@property (weak, nonatomic) IBOutlet UIImageView *catchImageView;
@property (strong, nonatomic) IBOutlet UITextField *flyField;
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
    self.catchImageView.image = self.catchInProgress.image;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initSpeciesPicker];
    [self initCatchImageView];
}

#pragma mark - IBActions
- (IBAction)finishedEnteringData:(UIButton *)sender {
    [self saveCatchInProgress];
    TRCatchDetailViewController *detail = [[TRCatchDetailViewController alloc] init];
    detail.catch = self.catchInProgress;
    [self.navigationController pushViewController:detail animated:YES];
}

- (void)saveCatchInProgress {
    self.catchInProgress.species = self.speciesField.text;
    self.catchInProgress.fly = self.flyField.text;
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

@end
