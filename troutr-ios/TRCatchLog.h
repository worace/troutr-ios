//
//  TRCatchLog.h
//  troutr-ios
//
//  Created by Horace Williams on 5/13/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TRCatch.h"

@interface TRCatchLog : NSObject
@property (nonatomic, readonly, copy) NSArray *allCatches;
- (TRCatch *)recordCatch:(TRCatch *)catch;
+ (instancetype)sharedStore;
- (BOOL)saveChanges;
@end
