//
//  TRFlyStore.m
//  troutr-ios
//
//  Created by Horace Williams on 5/14/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "TRFlyStore.h"

@interface TRFlyStore ()
@property (nonatomic, strong) NSArray *internalFlyList;
@property (nonatomic, strong) NSDictionary *internalFlyIndex;
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

- (NSArray *)internalFlyList {
    if (!_internalFlyList) {
        _internalFlyList = [@[@"Adams", @"Adams Female", @"Black Gnat", @"Blue Dun", @"Blue Quill", @"Blue Wing Olive", @"Dark Cahill", @"Dark Hendrickson", @"Ginger Quill", @"Gray Fox", @"Hare's Ear", @"Light Cahill", @"Light Hendrickson", @"March Brown", @"Mosquito", @"Pale Evening Dun", @"Pale Morning Dun", @"Quill Gordon", @"Red Quill", @"Royal Coachman", @"Pheasant Tail", @"Zug Bug", @"Black Ant", @"Black Flying Ant", @"Green Cricket", @"Red Flying Ant"] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    return _internalFlyList;
}

- (NSArray *)flyList {
    return [self.internalFlyList copy];
}

- (NSDictionary *)internalFlyIndex {
    if (!_internalFlyIndex) {
        _internalFlyIndex = [self generateIndexFromFlyList];
    }
    return _internalFlyIndex;
}

- (NSDictionary *)flyIndex {
    return [self.internalFlyIndex copy];
}

- (NSArray *)flyIndexKeys {
    return [[self.flyIndex allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSDictionary *)generateIndexFromFlyList {
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
    for (NSString *fly in self.flyList) {
        NSString *firstChar = [[fly substringToIndex:1] uppercaseString];
        if (!temp[firstChar]) { temp[firstChar] = [[NSMutableArray alloc] init]; }
        [temp[firstChar] addObject:fly];
    }
    NSMutableDictionary *tempWithNonMutable = [[NSMutableDictionary alloc] init];
    for (NSString *key in [temp allKeys]) {
        tempWithNonMutable[key] = [temp[key] copy];
    }
    return [tempWithNonMutable copy];
}

- (NSArray *)fliesForKey:(NSString *)key {
    NSArray *flies = self.flyIndex[key];
    if (flies) {
        return flies;
    } else {
        return @[];
    }
}
@end
