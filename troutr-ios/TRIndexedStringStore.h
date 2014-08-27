//
//  TRIndexedStringStore.h
//  troutr-ios
//
//  Created by Horace Williams on 6/22/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRIndexedStringStore : NSObject
@property (nonatomic, readonly, copy)NSDictionary *indexedList;
@property (nonatomic, readonly, copy)NSArray *sortedList;
- (NSArray *)indexKeys;
- (NSArray *)itemsForKey:(NSString *)key;
@end
