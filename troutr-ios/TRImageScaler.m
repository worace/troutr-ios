//
//  TRImageScaler.m
//  troutr-ios
//
//  Created by Horace Williams on 6/10/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "TRImageScaler.h"

@interface TRImageScaler ()
@property (nonatomic, strong) UIImage *image;
@end

@implementation TRImageScaler
- (instancetype)initWithImage:(UIImage *)image {
    self = [super init];
    if (self) {
        _image = image;
    }
    return self;
}

- (UIImage *)scaleToRatio:(double)ratio {
    CGSize sz = CGSizeMake(self.image.size.width*ratio, self.image.size.height*ratio);
    CGRect rect = CGRectMake(0, 0, sz.width, sz.height);

    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }

    [self.image drawInRect:rect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

- (UIImage*)scaleAndCropToSize:(CGSize)targetSize {
    double ratio;
    double delta;
    CGPoint offset;
    
    //make a new square size, that is the resized imaged width
    CGSize sz = CGSizeMake(targetSize.width, targetSize.width);
    
    //figure out if the picture is landscape or portrait, then
    //calculate scale factor and offset
    if (self.image.size.width > self.image.size.height) {
        ratio = targetSize.width / self.image.size.width;
        delta = (ratio*self.image.size.width - ratio*self.image.size.height);
        offset = CGPointMake(delta/2, 0);
    } else {
        ratio = targetSize.width / self.image.size.height;
        delta = (ratio*self.image.size.height - ratio*self.image.size.width);
        offset = CGPointMake(0, delta/2);
    }
    
    //make the final clipping rect based on the calculated values
    CGRect clipRect = CGRectMake(-offset.x, -offset.y,
                                 (ratio * self.image.size.width) + delta,
                                 (ratio * self.image.size.height) + delta);
    
    
    //start a new context, with scale factor 0.0 so retina displays get
    //high quality image
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(sz, YES, 0.0);
    } else {
        UIGraphicsBeginImageContext(sz);
    }
    UIRectClip(clipRect);
    [self.image drawInRect:clipRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

@end
