//
//  TRCamPreviewView.m
//  troutr-ios
//
//  Created by Horace Williams on 5/21/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//
#import "TRCamPreviewView.h"
#import <AVFoundation/AVFoundation.h>

@implementation TRCamPreviewView
+ (Class)layerClass {
    return [AVCaptureVideoPreviewLayer class];
}

- (AVCaptureSession *)session {
    return [(AVCaptureVideoPreviewLayer *)[self layer] session];
}

- (void)setSession:(AVCaptureSession *)session {
    [(AVCaptureVideoPreviewLayer *)[self layer] setSession:session];
}
@end
