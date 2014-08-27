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
        _internalList = [@[@"Adams", @"Adams Female", @"Black Gnat", @"Blue Dun", @"Blue Quill", @"Blue Wing Olive", @"Dark Cahill", @"Dark Hendrickson", @"Ginger Quill", @"Gray Fox", @"Hare's Ear", @"Light Cahill", @"Light Hendrickson", @"March Brown", @"Mosquito", @"Pale Evening Dun", @"Pale Morning Dun", @"Quill Gordon", @"Red Quill", @"Royal Coachman", @"Pheasant Tail", @"Zug Bug", @"Black Ant", @"Black Flying Ant", @"Green Cricket", @"Red Flying Ant"] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    NSLog(@"fly store returning internal list");
    return _internalList;
}

@end
