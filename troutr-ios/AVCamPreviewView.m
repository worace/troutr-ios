//
//  AVCamPreviewView.m
//  troutr-ios
//
//  Created by Horace Williams on 5/20/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "AVCamPreviewView.h"
#import <AVFoundation/AVFoundation.h>

@implementation AVCamPreviewView
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
