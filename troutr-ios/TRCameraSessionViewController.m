//
//  TRCameraSessionViewController.m
//  troutr-ios
//
//  Created by Horace Williams on 5/20/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "TRCameraSessionViewController.h"
#import "TRCamPreviewView.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>


static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

@interface TRCameraSessionViewController () <AVCaptureFileOutputRecordingDelegate>
//outlets
@property (nonatomic, weak) IBOutlet TRCamPreviewView *previewView;
@property (nonatomic, weak) IBOutlet UIButton *snapStillPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *recordVideoButton;

//managing AV session
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.

//output sources
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic) BOOL lockInterfaceRotation;

@end

@implementation TRCameraSessionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.session = [[AVCaptureSession alloc] init];
    self.previewView.session = self.session;
    
    [self checkDeviceAuthorizationStatus];
    
    self.sessionQueue = dispatch_queue_create("AVCaptureSession Queue", DISPATCH_QUEUE_SERIAL);
    
    dispatch_async(self.sessionQueue, ^{
        self.backgroundRecordingID = UIBackgroundTaskInvalid;
        
        NSError *error = nil;
        
//        AVCaptureDevice *videoDevice = [AVCamViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
//		AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];

        AVCaptureDevice *videoDevice = [TRCameraSessionViewController deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
        
        if (error) { NSLog(@"%@", error); }
        
        if ([self.session canAddInput:videoDeviceInput]) {
            [self.session addInput:videoDeviceInput];
            self.videoDeviceInput = videoDeviceInput;
            dispatch_async(dispatch_get_main_queue(), ^{
                // send to main queue b/c AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
                [self previewLayer].connection.videoOrientation = (AVCaptureVideoOrientation)self.interfaceOrientation;
            });
        }
        
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ([self.session canAddOutput:movieFileOutput]) {
            [self.session addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([connection isVideoStabilizationSupported])
                connection.enablesVideoStabilizationWhenAvailable = YES;
            self.movieFileOutput = movieFileOutput;
        }
        
        AVCaptureStillImageOutput *stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
        if ([self.session canAddOutput:stillImageOutput]) {
            stillImageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
            [self.session addOutput:stillImageOutput];
            self.stillImageOutput = stillImageOutput;
        }
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    dispatch_async(self.sessionQueue, ^{
        //        [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
        [self addObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:CapturingStillImageContext];
        [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
        
        //refocus when subject area changes
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:self.videoDeviceInput.device];
        //TODO: add runtime error handling observer
        
        [self.session startRunning];
    });
}

- (void)viewDidDisappear:(BOOL)animated
{
	dispatch_async([self sessionQueue], ^{
		[[self session] stopRunning];
		
		[[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        //		[[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
		
        //		[self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
		[self removeObserver:self forKeyPath:@"stillImageOutput.capturingStillImage" context:CapturingStillImageContext];
		[self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
	});
}

- (BOOL)prefersStatusBarHidden { return YES; }

//TODO Handle Rotation??
- (BOOL)shouldAutorotate {
    return !self.lockInterfaceRotation;
}

- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
	[[self previewLayer].connection setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}

- (AVCaptureVideoPreviewLayer *)previewLayer {
    return (AVCaptureVideoPreviewLayer *)self.previewView.layer;
}

- (AVCaptureVideoOrientation)currentPreviewOrientation {
    return (AVCaptureVideoOrientation)[[self previewLayer].connection videoOrientation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == CapturingStillImageContext) {
		if ([change[NSKeyValueChangeNewKey] boolValue])
            [self runStillImageCaptureAnimation];
	} else if (context == RecordingContext) {
        NSLog(@"observed recording context KVO");
        BOOL isRecording = [change[NSKeyValueChangeNewKey] boolValue];
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRecording) {
                NSLog(@"recording KVO is recording");
                self.recordVideoButton.titleLabel.text = @"recording, press to stop";
            } else {
                NSLog(@"recording KVO is no longer recording");
                self.recordVideoButton.titleLabel.text = @"record";
            }
        });
    }else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark Actions
- (IBAction)snapStillPhoto:(id)sender {
    dispatch_async(self.sessionQueue, ^{
        AVCaptureConnection *outputConnection = [self.stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        outputConnection.videoOrientation = [self previewLayer].connection.videoOrientation;
        
        [self.stillImageOutput captureStillImageAsynchronouslyFromConnection:outputConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
            if (imageDataSampleBuffer) {
                NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
                UIImage *image = [[UIImage alloc] initWithData:imageData];
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                [library writeImageToSavedPhotosAlbum:[image CGImage] orientation:(ALAssetOrientation)[image imageOrientation] completionBlock:nil];
                [self.delegate cameraSessionController:self didFinishPickingMediaWithInfo:@{@"image":image}];
            }
        }];
    });
}

- (IBAction)toggleMovieRecording:(id)sender {
    NSLog(@"toggleMoveRecording called");
    //todo - diisable record button if needed
    dispatch_async(self.sessionQueue, ^{
        if (![self.movieFileOutput isRecording]) {
            NSLog(@"toggleMovieREcording async is not recording");
            self.lockInterfaceRotation = YES;
            if ([[UIDevice currentDevice] isMultitaskingSupported]) {
                self.backgroundRecordingID = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil];
            }
            
            //Make sure the movie file output connection has the correct orientation before we record
            [[self.movieFileOutput connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[self currentPreviewOrientation]];
            [self disableCameraFlash];
            
            NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingString:@"troutrRecording"];
            NSLog(@"going to start recording with file output path: %@", outputFilePath);
            [self.movieFileOutput startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
        } else {
            NSLog(@"toggleMovieREcording async is recording, will stop it");
            [self.movieFileOutput stopRecording]; //will trigger delegate method which saves file
        }
    });
}

- (IBAction)focusAndExposeTap:(UIGestureRecognizer *)gestureRecognizer {
    //TBD
}

- (void)longPress:(UILongPressGestureRecognizer *)gr {
    if (gr.state == UIGestureRecognizerStateBegan) {
        //start recording
    } else if (gr.state == UIGestureRecognizerStateEnded) {
        //end recording
    }
}

- (void)subjectAreaDidChange:(NSNotification *)notification {
	CGPoint devicePoint = CGPointMake(.5, .5);
	[self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
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

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position {
	NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
	AVCaptureDevice *captureDevice = [devices firstObject];
	
	for (AVCaptureDevice *device in devices) {
		if ([device position] == position) {
			captureDevice = device;
			break;
		}
	}
    
	return captureDevice;
}

- (void)checkDeviceAuthorizationStatus
{
	NSString *mediaType = AVMediaTypeVideo;
	
	[AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
		if (granted) {
			[self setDeviceAuthorized:YES];
		} else {
			//Not granted access to mediaType
			dispatch_async(dispatch_get_main_queue(), ^{
				[[[UIAlertView alloc] initWithTitle:@"Camera Issue"
											message:@"Unable to access camera. Please change privacy settings"
										   delegate:self
								  cancelButtonTitle:@"OK"
								  otherButtonTitles:nil] show];
				[self setDeviceAuthorized:NO];
			});
		}
	}];
}

- (void)disableCameraFlash {
    [self setFlashMode:AVCaptureFlashModeOff forDevice:self.videoDeviceInput.device];
}

- (void)enableCameraFlash {
    [self setFlashMode:AVCaptureFlashModeAuto forDevice:self.videoDeviceInput.device];
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device {
    if ([device hasFlash] && [device isFlashModeSupported:flashMode])
	{
		NSError *error = nil;
		if ([device lockForConfiguration:&error])
		{
			[device setFlashMode:flashMode];
			[device unlockForConfiguration];
		}
		else {
			NSLog(@"%@", error);
		}
	}
}

#pragma mark Video File Output Delegate
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error {
    NSLog(@"capture output called with captureOutput: %@, outputFileUrl: %@, connections: %@, error: %@", captureOutput, outputFileURL, connections, error);
    if (error) {
        NSLog(@"error capturing video output: %@", error);
//        dispatch_async(dispatch_get_main_queue(), ^{
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"recording failed"
//                                                            message:@"there was an issue recording video. try again."
//                                                           delegate:self
//                                                  cancelButtonTitle:@"Cancel"
//                                                  otherButtonTitles:nil];
//            [alert show];
//        });
//        return;
    }
    
    self.lockInterfaceRotation = NO; //done recording so allow rotation;
    
    // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
    UIBackgroundTaskIdentifier backgroundRecordingID = self.backgroundRecordingID;
    self.backgroundRecordingID = UIBackgroundTaskInvalid;
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    NSLog(@"asset library initialized: %@", library);
    
    NSLog(@"checking if video is compatible: %hhd", [library videoAtPathIsCompatibleWithSavedPhotosAlbum:outputFileURL]);
    [library writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        NSLog(@"library write video at path finished with outputfileurl: %@ and assetUrl: %@", outputFileURL, assetURL);
        if (error) {
            NSLog(@"%@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"recording failed"
                                                            message:@"there was an issue recording video. try again."
                                                           delegate:self
                                                  cancelButtonTitle:@"Cancel"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            NSLog(@"no error in write video at path to saved photo albuM");
            //remove the temp video file now that we have saved to asset lib
            [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
            //halt background recording task
            if (backgroundRecordingID != UIBackgroundTaskInvalid) { [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID]; }
            NSLog(@"finished recording video; asset url is: %@", assetURL);
//            [self.delegate cameraSessionController:self didFinishPickingMediaWithInfo:@{@"videoUrl":assetURL}];
        }
    }];
}

#pragma mark UI Animations
- (void)runStillImageCaptureAnimation
{
	dispatch_async(dispatch_get_main_queue(), ^{
		[[self previewLayer] setOpacity:0.0];
		[UIView animateWithDuration:.25 animations:^{
			[[self previewLayer] setOpacity:1.0];
		}];
	});
}

@end
