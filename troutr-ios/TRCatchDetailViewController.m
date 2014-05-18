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
#import <MapKit/MapKit.h>

@interface TRCatchDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *speciesLabel;
@property (weak, nonatomic) IBOutlet UILabel *flyLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *catchImage;
;
@end

@implementation TRCatchDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.contentSize = self.contentView.frame.size;
    [self configureBackButton];
    [self configureMapDisplay];
}

- (void)configureBackButton {
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(popToRoot)];
    self.navigationItem.leftBarButtonItem = newBackButton;
}

- (void)configureMapDisplay {
    if (self.catch.location) {
        NSLog(@"catch has location, displaying map");
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.catch.location.coordinate, 500, 500);
        [self.mapView setRegion:region];
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:self.catch.location.coordinate];
        [self.mapView addAnnotation:annotation];
    } else {
        NSLog(@"no location, hide the map");
        self.mapView.hidden = YES;
    }
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
