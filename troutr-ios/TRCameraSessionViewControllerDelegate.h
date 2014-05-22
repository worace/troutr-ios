//
//  TRCameraSessionViewControllerDelegate.h
//  troutr-ios
//
//  Created by Horace Williams on 5/20/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TRCamViewController;

@protocol TRCameraSessionViewControllerDelegate <NSObject>
@required
- (void)cameraSessionController:(TRCamViewController *)cameraSessionController didFinishPickingMediaWithInfo:(NSDictionary *)info;
@end
