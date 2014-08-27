//
//  TRIndexedStringStore.m
//  troutr-ios
//
//  Created by Horace Williams on 6/22/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "TRIndexedStringStore.h"

@interface TRIndexedStringStore ()
@property (nonatomic, strong) NSArray *internalList;
@property (nonatomic, strong) NSDictionary *internalIndex;
@end

@implementation TRIndexedStringStore
- (NSDictionary *)indexedList {
    return [self.internalIndex copy];
}

- (NSArray *)sortedList {
    return [[self internalList] copy];
}

- (NSArray *)indexKeys {
    return [[self.indexedList allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSArray *)itemsForKey:(NSString *)key {
    NSArray *items = self.indexedList[key];
    if (items) {
        return items;
    } else {
        return @[];
    }
}

// override
- (NSArray *)internalList {
    return @[];
}

- (NSDictionary *)internalIndex {
    if (!_internalIndex) {
        _internalIndex = [self generateIndexFromList];
    }
    return _internalIndex;
}

- (NSDictionary *)generateIndexFromList {
    NSMutableDictionary *temp = [[NSMutableDictionary alloc] init];
    for (NSString *item in self.sortedList) {
        NSString *firstChar = [[item substringToIndex:1] uppercaseString];
        if (!temp[firstChar]) { temp[firstChar] = [[NSMutableArray alloc] init]; }
        [temp[firstChar] addObject:item];
    }
    NSMutableDictionary *tempWithNonMutable = [[NSMutableDictionary alloc] init];
    for (NSString *key in [temp allKeys]) {
        tempWithNonMutable[key] = [temp[key] copy];
    }
    return [tempWithNonMutable copy];
}


@end


