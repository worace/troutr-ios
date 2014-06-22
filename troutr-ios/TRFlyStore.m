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

- (NSArray *)internalList {
    if (!_internalList) {
        _internalList = [@[@"Adams", @"Adams Female", @"Black Gnat", @"Blue Dun", @"Blue Quill", @"Blue Wing Olive", @"Dark Cahill", @"Dark Hendrickson", @"Ginger Quill", @"Gray Fox", @"Hare's Ear", @"Light Cahill", @"Light Hendrickson", @"March Brown", @"Mosquito", @"Pale Evening Dun", @"Pale Morning Dun", @"Quill Gordon", @"Red Quill", @"Royal Coachman", @"Pheasant Tail", @"Zug Bug", @"Black Ant", @"Black Flying Ant", @"Green Cricket", @"Red Flying Ant"] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    return _internalList;
}

@end
