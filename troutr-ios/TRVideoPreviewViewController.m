//
//  TRVideoPreviewViewController.m
//  troutr-ios
//
//  Created by Horace Williams on 5/29/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "TRVideoPreviewViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "TRCatch.h"
#import "TRCatchDataEntryViewController.h"
#import <AssetsLibrary/AssetsLibrary.h>


@interface TRVideoPreviewViewController ()
@property (nonatomic, strong)NSURL *videoURL;
@property (nonatomic, strong)AVPlayer *player;

@end

@implementation TRVideoPreviewViewController
- (instancetype)initWithAssetUrl:(NSURL *)videoURL {
    self = [super init];
    if (self) {
        self.videoURL = videoURL;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initVideoPlayer];
    [self configureNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startVideoPlayer];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self stopVideoPlayer];
}

- (void)startVideoPlayer {
    if (self.player) { [self.player play]; }
}

- (void)stopVideoPlayer {
    if (self.player) { [self.player pause]; }
}

- (void)initVideoPlayer {
    self.player = [AVPlayer playerWithURL:self.videoURL];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoInProgressPlayerReachedEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.player currentItem]];
    
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.frame;
    [self.view.layer addSublayer:layer];
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
                               action:@selector(cancelVideo)];
    self.navigationItem.leftBarButtonItem = cancel;
    
    UIBarButtonItem *confirm = [[UIBarButtonItem alloc]
                                initWithTitle:@"confirm"
                                style:UIBarButtonItemStyleBordered
                                target:self
                                action:@selector(confirmVideo)];
    self.navigationItem.rightBarButtonItem = confirm;
}

- (void)videoInProgressPlayerReachedEnd:(NSNotification *)notification {
    AVPlayerItem *playerItem = [notification object];
    if (playerItem) {
        [playerItem seekToTime:kCMTimeZero];
    }
}

- (void)confirmVideo {
    //TODO: Background this to ensure it can complete if app goes to background
    NSLog(@"ready to begin writing to asset lib");
    [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:self.videoURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) { NSLog(@"%@", error); }
        NSLog(@"finished writing video, asset url is: %@", assetURL);
        [self advanceToCatchStep:assetURL];
    }];
}

- (void)advanceToCatchStep:(NSURL *)savedAssetURL {
    TRCatch *catch = [[TRCatch alloc] init];
    catch.videoAssetURL = savedAssetURL;
    TRCatchDataEntryViewController *dataEntry = [[TRCatchDataEntryViewController alloc] init];
    dataEntry.catchInProgress = catch;
    [self clearVideoTempFile];
    [self.navigationController pushViewController:dataEntry animated:YES];
}

- (void)cancelVideo {
    [self clearVideoTempFile];
    [[self navigationController] popViewControllerAnimated:NO];
}


- (void)clearVideoTempFile {
    [[NSFileManager defaultManager] removeItemAtURL:self.videoURL error:nil];
    self.videoURL = nil;
}

- (void)dealloc {
    [self clearVideoTempFile];
}
@end
