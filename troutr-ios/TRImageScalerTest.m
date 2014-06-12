//
//  TRImageScalerTest.m
//  troutr-ios
//
//  Created by Horace Williams on 6/10/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TRImageScaler.h"

@interface TRImageScalerTest : XCTestCase

@end

@implementation TRImageScalerTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testImageWithTooLargeWidthScalesDownInWidth
{
    UIImage *testImage = [self testImageWithSize:CGSizeMake(150, 100)];
    XCTAssertEqual(150, testImage.size.width);
    XCTAssertEqual(100, testImage.size.height);
    UIImage *scaled = [[[TRImageScaler alloc] initWithImage:testImage] scaleAndCropToSize:CGSizeMake(100, 100)];
    XCTAssertEqual(100, scaled.size.width);
    XCTAssertEqual(100, scaled.size.height);
}

- (UIImage *)testImageWithSize:(CGSize)size {
    CGRect rect = CGRectMake(0.0f, 0.0f, size.width, size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
