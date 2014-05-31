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
#import "TRImagePreviewViewController.h"
#import "TRVideoPreviewViewController.h"

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;
static void * ConfirmedMediaSelectionContext = &ConfirmedMediaSelectionContext;


@interface TRCamViewController () <AVCaptureFileOutputRecordingDelegate, UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *screenButton;
@property (nonatomic, weak) IBOutlet TRCamPreviewView *previewView;

@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSTimer *recordingProgressTimer;
@property (nonatomic, strong) NSDate *recordingStartedTimeStamp;

@property (nonatomic, strong) NSURL *videoInProgress;

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
    [self configureTransparentNavigationBar];
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
        [self registerKVOAndNotificationObservers];
        [self registerRuntimeErrorHandler];
		[[self session] startRunning];
	});
}

- (void)viewDidDisappear:(BOOL)animated
{
	dispatch_async([self sessionQueue], ^{
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

- (void)registerKVOAndNotificationObservers {
    [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized"
              options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
    [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage"
              options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:)
                                                 name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopCameraSession:)
                                                 name:@"TRCameraSessionConfirmedMediaSelection" object:nil];

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
    // add this to restore video
//    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(screenButtonLongPress:)];
//    longPress.allowableMovement = 50;
//    [self.screenButton addGestureRecognizer:longPress];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(snapStillImage:)];
    [self.screenButton addGestureRecognizer:tapGesture];
}

#pragma mark Actions

- (void)startMovieRecording {
    dispatch_async(self.sessionQueue, ^{
        if (![[self movieFileOutput] isRecording]) {
            NSLog(@"starting recording");
            [self setLockInterfaceRotation:YES];
            
            if ([[UIDevice currentDevice] isMultitaskingSupported])
            {
                // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library when AVCam is backgrounded. To conclude this background execution, -endBackgroundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the recorded file has been saved.
                self.backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithName:@"recordVideoToTempFile" expirationHandler:nil];
            }
            
            // Update the orientation on the movie file output video connection before starting recording.
            [[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];
            
            // Turning OFF flash for video recording
            [TRCamViewController setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
            
            // Start recording to a temporary file.; clear it first to make sure we have a clean slate
            NSString *filename = [NSString stringWithFormat:@"%f", [[NSDate date] timeIntervalSince1970] ];
            NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[filename stringByAppendingPathExtension:@"mov"]];
            [[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
        }
    });
}

- (void)stopMovieRecording {
    dispatch_async(self.sessionQueue, ^{
        NSLog(@"stopping recording");
        [[self movieFileOutput] stopRecording];
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
        [self startMovieRecording];
    } else if (gr.state == UIGestureRecognizerStateEnded) {
        [self resetProgressBar];
        [self stopMovieRecording];
    }
}

- (void)stopCameraSession:(id)sender {
    [self.session stopRunning];
}

#pragma mark File Output Delegate
// for video output
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{

    UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
    if (backgroundRecordingID != UIBackgroundTaskInvalid)
        [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
    [self setBackgroundRecordingID:UIBackgroundTaskInvalid];

    if (!self.videoInProgress) {
        self.videoInProgress = outputFileURL;
        NSLog(@"captured output; setting output url: %@", outputFileURL);
        if (error) {
            NSLog(@"%@", error);
        } else {
            [self setLockInterfaceRotation:NO];
            [self displayVideoConfirmationModeUI:outputFileURL];
        }
        
    }
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

- (void)configureTransparentNavigationBar {
    [[self navigationController].navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [self navigationController].navigationBar.shadowImage = [UIImage new];
    [self navigationController].navigationBar.translucent = YES;
}

- (void)displayVideoConfirmationModeUI:(NSURL *)videoURL {
    TRVideoPreviewViewController *preview = [[TRVideoPreviewViewController alloc] initWithAssetUrl:videoURL];
    [[self navigationController] pushViewController:preview animated:NO];
}

- (void)displayStillImageConfirmationModeUIForImageData:(NSData *)imageData {
    UIImage *image = [[UIImage alloc] initWithData:imageData];
    TRImagePreviewViewController *preview = [[TRImagePreviewViewController alloc] initWithImage:image];
    [[self navigationController] pushViewController:preview animated:NO];
}

#pragma mark Utility / Helper

@end
