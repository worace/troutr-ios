//
//  TRImageScaler.h
//  troutr-ios
//
//  Created by Horace Williams on 6/10/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRImageScaler : NSObject
- (instancetype)initWithImage:(UIImage *)image;
- (UIImage *)scaleAndCropToSize:(CGSize)targetSize;
- (UIImage *)scaleToRatio:(double)ratio;
@end
