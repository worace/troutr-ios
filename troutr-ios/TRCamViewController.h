//
//  TRCamViewController.h
//  troutr-ios
//
//  Created by Horace Williams on 5/21/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TRCameraSessionViewControllerDelegate.h"

@interface TRCamViewController : UIViewController
@property (nonatomic, weak) NSObject<TRCameraSessionViewControllerDelegate> *delegate;
@end
