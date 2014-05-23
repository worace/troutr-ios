//
//  TRCamViewController.m
//  troutr-ios
//
//  Created by Horace Williams on 5/21/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//
#import "TRCamViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>

#import "TRCamPreviewView.h"

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface TRCamViewController () <AVCaptureFileOutputRecordingDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *screenButton;
@property (nonatomic, weak) IBOutlet TRCamPreviewView *previewView;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSTimer *recordingProgressTimer;
@property (nonatomic, strong) NSDate *recordingStartedTimeStamp;

@property (nonatomic, strong) UIImageView *stillImageInProgress;
@property (nonatomic, strong) NSURL *videoInProgress;


- (IBAction)toggleMovieRecording:(id)sender;
- (IBAction)snapStillImage:(id)sender;
- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer;

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;

@end

@implementation TRCamViewController

- (BOOL)isSessionRunningAndDeviceAuthorized
{
	return [[self session] isRunning] && [self isDeviceAuthorized];
}

+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
{
	return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
    [self hideNavigationBar];
    [self initCaptureSession];
	[self checkDeviceAuthorizationStatus];
    [self initSerialSessionQueue];
    [self registerGestureRecognizers];
	
	dispatch_async(self.sessionQueue, ^{
		[self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        [self registerVideoDeviceWithSession];
        [self registerAudioDeviceWithSession];
        [self registerMovieFileOutputWithSession];
        [self registerStillImageOutputWithSession];
	});
}

- (void)viewWillAppear:(BOOL)animated
{
	dispatch_async([self sessionQueue], ^{
        [self addKVOAndNotificationObservers];
        [self registerRuntimeErrorHandler];
		[[self session] startRunning];
	});
    if (self.videoInProgress || self.stillImageInProgress) {
        self.screenButton.enabled = NO;
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
	dispatch_async([self sessionQueue], ^{
		[[self session] stopRunning];
		[self removeKVOAndNotificationObservers];
	});
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

- (BOOL)shouldAutorotate
{
	// Disable autorotation of the interface when recording is in progress.
	return ![self lockInterfaceRotation];
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
	if (context == CapturingStillImageContext)
	{
		BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
		
		if (isCapturingStillImage)
		{
			[self runStillImageCaptureAnimation];
		}
	}
	else if (context == SessionRunningAndDeviceAuthorizedContext)
	{
        NSLog(@"session running observation");
//		BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
//		
//		dispatch_async(dispatch_get_main_queue(), ^{
//			if (isRunning)
//			{
//                [self.screenButton setEnabled:YES];
//
//			}
//			else
//			{
//                [self.screenButton setEnabled:NO];
//			}
//		});
	}
	else
	{
		[super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
	}
}

#pragma mark Initialization / Setup
- (void)initCaptureSession {
	AVCaptureSession *session = [[AVCaptureSession alloc] init];
    session.sessionPreset = AVCaptureSessionPresetMedium;
    self.session = session;
    AVCaptureVideoPreviewLayer *layer = (AVCaptureVideoPreviewLayer *)self.previewView.layer;
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [[self previewView] setSession:session];
}

- (void)initSerialSessionQueue {
	//Mutate AVCaptureSession off of main thread b/c it is expensive ([AVCaptureSession startRunning] esp.)
    //but do it on serial queue b/c it's not threadsafe
	dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
	[self setSessionQueue:sessionQueue];
}

- (void)addKVOAndNotificationObservers {
    [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized"
              options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
    [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage"
              options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:)
                                                 name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
}

- (void)removeKVOAndNotificationObservers {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
    [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
    [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
    [self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
}

- (void)registerVideoDeviceWithSession {
    NSError *error = nil;
    
    AVCaptureDevice *videoDevice = [TRCamViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
    AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
    if (error) {
        NSLog(@"%@", error);
    }
    
    if ([self.session canAddInput:videoDeviceInput]) {
        [self.session addInput:videoDeviceInput];
        [self setVideoDeviceInput:videoDeviceInput];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            // Why are we dispatching this to the main queue?
            // Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
            // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
            [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
        });
    }
}

- (void)registerMovieFileOutputWithSession {
    AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    if ([self.session canAddOutput:movieFileOutput])
    {
        [self.session addOutput:movieFileOutput];
        AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([connection isVideoStabilizationSupported])
            [connection setEnablesVideoStabilizationWhenAvailable:YES];
        [self setMovieFileOutput:movieFileOutput];
    }
}

- (void)registerStillImageOutputWithSession {
    AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    if ([self.session canAddOutput:stillImageOutput])
    {
        [stillImageOutput setOutputSettings:@{AVVideoCodecKey : AVVideoCodecJPEG}];
        [self.session addOutput:stillImageOutput];
        [self setStillImageOutput:stillImageOutput];
    }
}

- (void)registerAudioDeviceWithSession {
    NSError *error = nil;
    
    AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
    AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
    
    if (error) {
        NSLog(@"%@", error);
    }
    
    if ([self.session canAddInput:audioDeviceInput]) {
        [self.session addInput:audioDeviceInput];
    }
}

- (void)registerRuntimeErrorHandler {
    __weak TRCamViewController *weakSelf = self;
    [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
        TRCamViewController *strongSelf = weakSelf;
        dispatch_async([strongSelf sessionQueue], ^{
            // Manually restarting the session since it must have been stopped due to an error.
            [[strongSelf session] startRunning];
        });
    }]];
}

- (void)registerGestureRecognizers {
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(screenButtonLongPress:)];
    longPress.allowableMovement = 50;
    [self.screenButton addGestureRecognizer:longPress];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(snapStillImage:)];
    [self.screenButton addGestureRecognizer:tapGesture];
}

#pragma mark Actions

- (IBAction)toggleMovieRecording:(id)sender
{
	dispatch_async([self sessionQueue], ^{
		if (![[self movieFileOutput] isRecording]) {
			[self setLockInterfaceRotation:YES];
			
			if ([[UIDevice currentDevice] isMultitaskingSupported])
			{
				// Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saved.
				[self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
			}
			
			// Update the orientation on the movie file output video connection before starting recording.
			[[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
			
			// Turning OFF flash for video recording
			[TRCamViewController setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
			
			// Start recording to a temporary file.; clear it first to make sure we have a clean slate
            [self clearVideoInProgressTempFile];
			NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
			[[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
		}
		else
		{
			[[self movieFileOutput] stopRecording];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.screenButton.enabled = NO;//stop recording; go into confirm; don't allow button
            });

		}
	});
}

- (void)displayRecordingProgressBar {
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    CGFloat width = self.view.frame.size.width;
    self.progressView.frame = CGRectMake(0, 0, width, 0);
    [self.progressView setTransform:CGAffineTransformMakeScale(1.0, 5.0)];
    [self.view addSubview:self.progressView];
    
    self.recordingStartedTimeStamp = [NSDate date];
    self.recordingProgressTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateProgressBarWithTimer:) userInfo:nil repeats:YES];
}

- (void)resetProgressBar {
    [self.recordingProgressTimer invalidate];
    self.recordingProgressTimer = nil;
    self.recordingStartedTimeStamp = nil;
    [self.progressView removeFromSuperview];
    self.progressView = nil;
}

- (void)updateProgressBarWithTimer:(NSTimer *)timer {
    NSTimeInterval timeAllowed = 8;
    NSTimeInterval elapsedTime = [[NSDate date] timeIntervalSinceDate:self.recordingStartedTimeStamp];
    float percentageElapsed = elapsedTime / timeAllowed;
    self.progressView.progress = percentageElapsed;
}

- (IBAction)snapStillImage:(id)sender
{
    if (!self.stillImageInProgress) {
        dispatch_async([self sessionQueue], ^{
            // Update the orientation on the still image output video connection before capturing.
            [[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
            
            // Flash set to Auto for Still Capture
            [TRCamViewController setFlashMode:AVCaptureFlashModeAuto forDevice:[[self videoDeviceInput] device]];
            
            // Capture a still image.
            [[self stillImageOutput] captureStillImageAsynchronouslyFromConnection:[[self stillImageOutput] connectionWithMediaType:AVMediaTypeVideo] completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                if (imageDataSampleBuffer) {
                    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self displayStillImageConfirmationModeUIForImageData:imageData];
                    });
                }
            }];
        });
    }
}

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer
{
	CGPoint devicePoint = [(AVCaptureVideoPreviewLayer *)[[self previewView] layer] captureDevicePointOfInterestForPoint:[gestureRecognizer locationInView:[gestureRecognizer view]]];
	[self focusWithMode:AVCaptureFocusModeAutoFocus exposeWithMode:AVCaptureExposureModeAutoExpose atDevicePoint:devicePoint monitorSubjectAreaChange:YES];
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
	CGPoint devicePoint = CGPointMake(.5, .5);
	[self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

- (void)screenButtonLongPress:(UILongPressGestureRecognizer *)gr {
    if (gr.state == UIGestureRecognizerStateBegan) {
        [self displayRecordingProgressBar];
        [self toggleMovieRecording:nil];
    } else if (gr.state == UIGestureRecognizerStateEnded) {
        [self resetProgressBar];
        [self toggleMovieRecording:nil];
    }
}

- (void)videoInProgressPlayerReachedEnd:(NSNotification *)notification {
    NSLog(@"player reached end");
    AVPlayerItem *playerItem = [notification object];
    if (playerItem) {
        [playerItem seekToTime:kCMTimeZero];
    }
}

#pragma mark File Output Delegate
// for video output
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{

    if (!self.videoInProgress) {
        self.videoInProgress = outputFileURL;
        NSLog(@"captured output; setting output url: %@", outputFileURL);
        if (error)
            NSLog(@"%@", error);
        
        [self setLockInterfaceRotation:NO];
        
        [self displayVideoConfirmationModeUI];
    }
}

#pragma mark Media Cancel Confirm
- (void)confirmVideo {
    NSLog(@"confirm video!");
    [self writeVideoInProgressToCameraRoll];
}

- (void)cancelVideo {
    NSLog(@"cancel video");
    [self hideNavigationBar];
    [[self.view.layer.sublayers lastObject] removeFromSuperlayer];
    [self resetProgressBar];
    self.screenButton.enabled = YES;//cancelling video; re-enable screen interaction
    [self clearVideoInProgressTempFile];
}

- (void)cancelStillImage {
    NSLog(@"cancel");
    self.screenButton.enabled = YES;
    [self.stillImageInProgress removeFromSuperview];
    self.stillImageInProgress = nil;
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}

- (void)confirmStillImage {
    UIImage *image = self.stillImageInProgress.image;
    NSLog(@"confirm; image is %@", image);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[[ALAssetsLibrary alloc] init] writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
        NSLog(@"finished writing still image to photo library");
    });
    [self.delegate cameraSessionController:self didFinishPickingMediaWithInfo:@{@"image":image}];
    
}

- (void)writeVideoInProgressToCameraRoll {
    // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
	UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
	[self setBackgroundRecordingID:UIBackgroundTaskInvalid];
	NSLog(@"ready to begin writing to asset lib");
	[[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:self.videoInProgress completionBlock:^(NSURL *assetURL, NSError *error) {
		if (error)
			NSLog(@"%@", error);
        
        [self clearVideoInProgressTempFile];
		
		if (backgroundRecordingID != UIBackgroundTaskInvalid)
			[[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
        NSLog(@"finished writing video, asset url is: %@", assetURL);
        [self.delegate cameraSessionController:self didFinishPickingMediaWithInfo:@{@"videoAssetURL":assetURL}];
	}];
}

#pragma mark Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
	dispatch_async([self sessionQueue], ^{
		AVCaptureDevice *device = [[self videoDeviceInput] device];
		NSError *error = nil;
		if ([device lockForConfiguration:&error])
		{
			if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
			{
				[device setFocusMode:focusMode];
				[device setFocusPointOfInterest:point];
			}
			if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
			{
				[device setExposureMode:exposureMode];
				[device setExposurePointOfInterest:point];
			}
			[device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
			[device unlockForConfiguration];
		}
		else
		{
			NSLog(@"%@", error);
		}
	});
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
	if ([device hasFlash] && [device isFlashModeSupported:flashMode])
	{
		NSError *error = nil;
		if ([device lockForConfiguration:&error])
		{
			[device setFlashMode:flashMode];
			[device unlockForConfiguration];
		}
		else
		{
			NSLog(@"%@", error);
		}
	}
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
	AVCaptureDevice *captureDevice = [devices firstObject];
	
	for (AVCaptureDevice *device in devices)
	{
		if ([device position] == position)
		{
			captureDevice = device;
			break;
		}
	}
	
	return captureDevice;
}

#pragma mark UI

- (void)runStillImageCaptureAnimation
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[[self previewView] layer] setOpacity:0.0];
		[UIView animateWithDuration:.25 animations:^{
			[[[self previewView] layer] setOpacity:1.0];
		}];
	});
}

- (void)checkDeviceAuthorizationStatus
{
	NSString *mediaType = AVMediaTypeVideo;
	
	[AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
		if (granted)
		{
			//Granted access to mediaType
			[self setDeviceAuthorized:YES];
		}
		else
		{
			//Not granted access to mediaType
			dispatch_async(dispatch_get_main_queue(), ^{
				[[[UIAlertView alloc] initWithTitle:@"AVCam!"
											message:@"AVCam doesn't have permission to use Camera, please change privacy settings"
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
				[self setDeviceAuthorized:NO];
			});
		}
	}];
}

- (void)hideNavigationBar {
    [[self navigationController] setNavigationBarHidden:YES animated:NO];
}

- (void)displayVideoConfirmationModeUI {
    AVPlayer *player = [AVPlayer playerWithURL:self.videoInProgress];
    player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(videoInProgressPlayerReachedEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[player currentItem]];
    
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:player];
    layer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    layer.frame = self.view.frame;
    [self.view.layer addSublayer:layer];
    [player play];

    
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

- (void)displayStillImageConfirmationModeUIForImageData:(NSData *)imageData {
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = self.view.frame;
    
    self.stillImageInProgress = imageView;
    [self.view addSubview:imageView];
    
    [[self navigationController].navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self navigationController].navigationBar.shadowImage = [UIImage new];
    [self navigationController].navigationBar.translucent = YES;
    [[self navigationController] setNavigationBarHidden:NO animated:NO];
    
    UIBarButtonItem *cancel = [[UIBarButtonItem alloc]
                               initWithTitle:@"cancel"
                               style:UIBarButtonItemStyleBordered
                               target:self
                               action:@selector(cancelStillImage)];
    self.navigationItem.leftBarButtonItem = cancel;
    
    UIBarButtonItem *confirm = [[UIBarButtonItem alloc]
                                initWithTitle:@"confirm"
                                style:UIBarButtonItemStyleBordered
                                target:self
                                action:@selector(confirmStillImage)];
    self.navigationItem.rightBarButtonItem = confirm;
}

#pragma mark Utility / Helper

- (void)clearVideoInProgressTempFile {
    [[NSFileManager defaultManager] removeItemAtURL:self.videoInProgress error:nil];
    self.videoInProgress = nil;
}


@end
