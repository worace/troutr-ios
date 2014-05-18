//
//  TRCatchDetailViewController.m
//  troutr-ios
//
//  Created by Horace Williams on 5/13/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "TRCatchDetailViewController.h"
#import "TRCatchLog.h"
#import "TRCatch.h"

@interface TRCatchDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *speciesLabel;
@property (weak, nonatomic) IBOutlet UILabel *flyLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UIImageView *catchImage;
;
@end

@implementation TRCatchDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configureBackButton];
}

- (void)configureBackButton {
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(popToRoot)];
    self.navigationItem.leftBarButtonItem = newBackButton;
}

- (void)popToRoot {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self displayCatchImage];
    [self displayCatchInfo];
    [self displayLocationInfo];
}

- (void)displayCatchInfo {
    self.speciesLabel.text = [@"Species: " stringByAppendingString:self.catch.species];
    self.flyLabel.text = [@"Caught on: " stringByAppendingString:self.catch.fly];
    self.dateLabel.text = [NSString stringWithFormat:@"%@", self.catch.dateCreated];
}

- (void)displayCatchImage {
    self.catchImage.contentMode = UIViewContentModeScaleAspectFit;
    self.catchImage.image = self.catch.image;

}

- (void)displayLocationInfo {
    if (self.catch.location) {
        self.locationLabel.text = [NSString stringWithFormat:@"%f, %f", self.catch.location.coordinate.latitude, self.catch.location.coordinate.longitude];
    } else {
        self.locationLabel.text = @"no location data available";
    }
}

@end
