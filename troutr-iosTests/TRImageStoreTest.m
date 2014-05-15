//
//  TRImageStoreTest.m
//  troutr-ios
//
//  Created by Horace Williams on 5/14/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TRImageStore.h"

@interface TRImageStoreTest : XCTestCase

@end

@implementation TRImageStoreTest

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testSetImageWithNilDoesNothing
{
    [[TRImageStore sharedStore] setImage:nil forKey:@"mykey"];
    XCTAssertNil([[TRImageStore sharedStore] imageForKey:@"mykey"]);
}

@end
