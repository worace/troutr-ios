//
//  TRColors.m
//  troutr-ios
//
//  Created by Horace Williams on 5/19/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "TRColors.h"

#define UIColorFromHex(hexValue) [UIColor \
colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 \
green:((float)((hexValue & 0xFF00) >> 8))/255.0 \
blue:((float)(hexValue & 0xFF))/255.0 alpha:1.0]

#define UIColorFromHexWithAlpha(hexValue,a) [UIColor \
colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 \
green:((float)((hexValue & 0xFF00) >> 8))/255.0 \
blue:((float)(hexValue & 0xFF))/255.0 alpha:a]

@implementation TRColors

+(UIColor *)troutrGreen {
    return UIColorFromHex(0x99a306);
}

+(UIColor *)troutrTeal {
    return UIColorFromHex(0x05eeea);
}


@end
