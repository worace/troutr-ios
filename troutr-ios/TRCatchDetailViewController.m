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
#import "TRColors.h"
#import <MapKit/MapKit.h>

@interface TRCatchDetailViewController ()
@property (weak, nonatomic) IBOutlet UILabel *speciesLabel;
@property (weak, nonatomic) IBOutlet UILabel *flyLabel;
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
    [self configureNavBar];
    [self configureMapDisplay];
    [self addGestureRecognizers];
    NSLog(@"view did load");
}

- (void)viewDidLayoutSubviews {
    self.scrollView.contentSize = self.contentView.frame.size;
}

- (void)configureNavBar {
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(popToRoot)];
    newBackButton.tintColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = newBackButton;
    
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
    [self setNeedsStatusBarAppearanceUpdate];
}

-(UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (void)addGestureRecognizers {
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(popToRoot)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeRight];
}

- (void)configureMapDisplay {
    if (self.catch.location) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.catch.location.coordinate, 500, 500);
        [self.mapView setRegion:region];
        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:self.catch.location.coordinate];
        [self.mapView addAnnotation:annotation];
    } else {
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
}

- (void)displayCatchInfo {
    self.speciesLabel.text = self.catch.species;
    self.speciesLabel.textColor = [TRColors troutrGreen];
    self.flyLabel.text = [@"Caught on: " stringByAppendingString:self.catch.fly];
    if (self.catch.dateCreated) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateStyle:NSDateFormatterMediumStyle];
        self.dateLabel.text = [formatter stringFromDate:self.catch.dateCreated];
    }
}

- (void)displayCatchImage {
    self.catchImage.contentMode = UIViewContentModeScaleAspectFit;
    self.catchImage.image = self.catch.image;

}

@end
