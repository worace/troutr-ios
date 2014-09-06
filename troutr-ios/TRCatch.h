//
//  TRCatch.h
//  troutr-ios
//
//  Created by Horace Williams on 5/13/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TRCatch : NSObject <NSCoding>
@property (nonatomic, strong) NSString *species;
@property (nonatomic, strong) NSString *fly;
@property (nonatomic, copy) NSString *uid;
@property (nonatomic, strong)CLLocation *location;
@property (nonatomic, strong)NSDate *dateCreated;
@property (nonatomic, strong) NSURL *videoAssetURL;
@property (nonatomic, strong) UIImage *image;
@end
