//
//  TRFlyStore.h
//  troutr-ios
//
//  Created by Horace Williams on 5/14/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRFlyStore : NSObject
@property (nonatomic, readonly, copy)NSDictionary *flyIndex;
@property (nonatomic, readonly, copy)NSArray *flyList;
+ (instancetype)sharedStore;
- (NSArray *)flyList;
- (NSArray *)flyIndexKeys;
- (NSArray *)fliesForKey:(NSString *)key;
@end
