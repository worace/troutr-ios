//
//  TRCatchImagePickerViewController.h
//  troutr-ios
//
//  Created by Horace Williams on 5/14/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TRCatch;

@interface TRCatchImagePickerViewController : UIViewController
@property (nonatomic, strong) UIImage *selectedImage;
@property (nonatomic, strong) TRCatch *catchInProgress;
@end
