//
//  TRCamPreviewView.h
//  troutr-ios
//
//  Created by Horace Williams on 5/21/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVCaptureSession;

@interface TRCamPreviewView : UIView
@property (nonatomic) AVCaptureSession *session;
@end
