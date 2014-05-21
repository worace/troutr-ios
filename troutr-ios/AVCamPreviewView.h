//
//  AVCamPreviewView.h
//  troutr-ios
//
//  Created by Horace Williams on 5/20/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCaptureSession;

@interface AVCamPreviewView : UIView
@property (nonatomic) AVCaptureSession *session;
@end
