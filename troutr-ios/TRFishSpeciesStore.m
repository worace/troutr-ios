//
//  TRFishSpeciesStore.m
//  troutr-ios
//
//  Created by Horace Williams on 8/26/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "TRFishSpeciesStore.h"

@interface TRFishSpeciesStore ()
@property (nonatomic, strong) NSArray *internalList;
@end

@implementation TRFishSpeciesStore
+ (instancetype)sharedStore {
    static TRFishSpeciesStore *sharedStore;
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
        NSLog(@"fish store gnereating internal list");
        _internalList = [@[@"Bass (Largemouth)", @"Bass (Smallmouth)", @"Bass (Peacock)", @"Bass (Redeye)", @"Bass (Spotted)", @"Bluefish", @"Bluegill", @"Bonefish", @"Carp", @"Catfish", @"Crappie", @"Golden Dorado", @"Grayling", @"Longear sunfish", @"Muskie", @"Northern pike", @"Perch", @"Permit", @"Pike", @"Pompano", @"Red drum", @"Redbreast sunfish", @"Salmon (Atlantic)", @"Salmon (Chinook/King)", @"Salmon (Chum)", @"Salmon (Coho)", @"Salmon (Pink)", @"Salmon (Sockeye)", @"Snook", @"Speckled Trout (Spec)", @"Striped Bass", @"Taimen", @"Tarpon (Atlantic / King)", @"Tarpon (Indo-Pacific)", @"Trout (Apache)", @"Trout (Bonneville Cutthroat)", @"Trout (Brook)", @"Trout (Brown)", @"Trout (Coastal Cutthroat)", @"Trout (Colorado River Cutthroat)", @"Trout (Golden)", @"Trout (Greenback Cutthroat)", @"Trout (Lake)", @"Trout (Rainbow)", @"Trout (Redside)", @"Trout (Rio Grande Cutthroat)", @"Trout (Snake River fine-spotted)", @"Trout (Westslope Cutthroat)", @"Trout (Yellowstone Cutthroat)", @"Walleye", @"White bass", @"Whitefish"] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    NSLog(@"fish store returning internal list");
    return _internalList;
}
@end
