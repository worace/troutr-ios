//
//  TRFlyStoreTest.m
//  troutr-ios
//
//  Created by Horace Williams on 5/14/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TRFlyStore.h"

@interface TRFlyStoreTest : XCTestCase

@end

@implementation TRFlyStoreTest

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

-(void)testSharedStoreGivesInstanceOfStore {
    XCTAssertEqual([TRFlyStore class], [[TRFlyStore sharedStore] class]);
    XCTAssertEqual([TRFlyStore sharedStore], [TRFlyStore sharedStore]);
}

- (void)testFlyListGivesAListOfFlies
{
    XCTAssertEqual(26, [[[TRFlyStore sharedStore ] sortedList] count]);
}

- (void)testFlyListIsSorted {
    NSArray *knownSorted = [[[TRFlyStore sharedStore] sortedList] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    XCTAssertEqualObjects(knownSorted, [[TRFlyStore sharedStore] sortedList]);
}

- (void)testindexedListKeysDictOfFlies {
    NSDictionary *flies = [[TRFlyStore sharedStore ] indexedList];
    NSArray *expected = @[@"Adams", @"Adams Female"];
    XCTAssertEqualObjects(expected, flies[@"A"]);
}

- (void)testFliesForKeyGivesEmptyArrayForBadKey {
    XCTAssertEqualObjects(@[], [[TRFlyStore sharedStore] itemsForKey:@"agdssdgsdg"]);
}

- (void)testFliesForIndexGivesFliesForProperKey {
    NSArray *expected = @[@"Adams", @"Adams Female"];
    XCTAssertEqualObjects(expected, [[TRFlyStore sharedStore] itemsForKey:@"A"]);
}

- (void)testFlyIndexKeysIsSorted {
    NSArray *expected = [[[TRFlyStore sharedStore].indexedList allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    XCTAssertEqualObjects(expected, [[TRFlyStore sharedStore] indexKeys]);
}
@end
