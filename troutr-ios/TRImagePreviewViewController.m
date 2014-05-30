//
//  TRImagePreviewViewController.m
//  troutr-ios
//
//  Created by Horace Williams on 5/29/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "TRImagePreviewViewController.h"
#import "TRCatch.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "TRCatchDataEntryViewController.h"


@interface TRImagePreviewViewController ()
@property (nonatomic, strong) UIImage *image;
@end

@implementation TRImagePreviewViewController

- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        self.image = image;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initImageView];
    [self configureNavigationBar];
}

- (void)initImageView {
    UIImageView *imageView = [[UIImageView alloc] initWithImage:self.image];
    imageView.frame = self.view.frame;
    [self.view addSubview:imageView];
}


- (void)configureNavigationBar {
    [[self navigationController].navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self navigationController].navigationBar.shadowImage = [UIImage new];
    [self navigationController].navigationBar.translucent = YES;
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]
                               initWithTitle:@"cancel"
                               style:UIBarButtonItemStyleBordered
                               target:self
                               action:@selector(cancelImage)];
    self.navigationItem.leftBarButtonItem = cancel;
    
    UIBarButtonItem *confirm = [[UIBarButtonItem alloc]
                                initWithTitle:@"confirm"
                                style:UIBarButtonItemStyleBordered
                                target:self
                                action:@selector(confirmImage)];
    self.navigationItem.rightBarButtonItem = confirm;
}

- (void)confirmImage {
    NSLog(@"confirm Image");
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[self.image CGImage] orientation:(ALAssetOrientation)[self.image imageOrientation] completionBlock:nil];
        NSLog(@"finished writing still image to photo library");
    });
    TRCatch *catch = [[TRCatch alloc] init];
    catch.image = self.image;
    TRCatchDataEntryViewController *dataEntry = [[TRCatchDataEntryViewController alloc] init];
    dataEntry.catchInProgress = catch;
    [self.navigationController pushViewController:dataEntry animated:YES];
}

- (void)cancelImage {
    [[self navigationController] popViewControllerAnimated:NO];
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}
@end
