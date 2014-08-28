//
//  TRFlyStore.m
//  troutr-ios
//
//  Created by Horace Williams on 5/14/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "TRFlyStore.h"

@interface TRFlyStore ()
@property (nonatomic, strong) NSArray *internalList;
@end

@implementation TRFlyStore
+ (instancetype)sharedStore {
    static TRFlyStore *sharedStore;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^(void) {
        if (!sharedStore) {
            sharedStore = [[self alloc] initPrivate];
        }
    });
    return sharedStore;
}

- (instancetype)initPrivate {
    self = [super init];
    if (self) {
    }
    return self;
}

- (NSArray *)internalList {
    if (!_internalList) {
        NSLog(@"fly sotre generating internal list");
        _internalList = [@[@"Adams", @"Parachute Adams", @"Griffith's Gnat", @"Blue Quill", @"Blue Wing Olive", @"Dark Cahill", @"Hendrickson", @"Ginger Quill", @"Gray Fox", @"Hare's Ear", @"Light Cahill", @"March Brown", @"Pale Evening Dun", @"Pale Morning Dun", @"Quill Gordon", @"Royal Coachman", @"Pheasant Tail", @"Zug Bug", @"Black Ant", @"Black Flying Ant", @"Green Cricket", @"Red Flying Ant", @"Woolly Bugger", @"Royal Wulff", @"Elk Hair Caddis", @"Yellow Sally", @"Prince Nymph", @"Zebra Midge", @"Foam Hopper", @"Chernobyl Ant", @"Sculpin", @"Dave's Hopper", @"Parachute Ant", @"Deer Hair Bug", @"Bass Popper", @"Stonefly Nymph", @"Stonefly Dry"] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    NSLog(@"fly store returning internal list");
    return _internalList;
}

@end
