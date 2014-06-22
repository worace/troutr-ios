//
//  TRCatchLog.m
//  troutr-ios
//
//  Created by Horace Williams on 5/13/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "TRCatchLog.h"

@interface TRCatchLog ()
@property (nonatomic, strong) NSMutableArray *internalCatchLog;
@end

@implementation TRCatchLog
+(instancetype)sharedStore {
    static TRCatchLog *sharedStore;
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    return sharedStore;
}

- (instancetype)init {
    return [[self class] sharedStore];
}

- (instancetype)initPrivate {
    self = [super init];
    return self;
}

- (NSArray *)allCatches {
    return [self.internalCatchLog copy];
}

- (TRCatch *)recordCatch:(TRCatch *)catch {
    [self.internalCatchLog addObject:catch];
    [self sortLog];
    [self saveChanges];
    return catch;
}

- (NSMutableArray *)internalCatchLog {
    if (!_internalCatchLog) {
        _internalCatchLog = [self loadSavedLog];
        [self sortLog];
    }
    return _internalCatchLog;
}

- (BOOL)saveChanges {
    NSLog(@"saving changes");
    return [NSKeyedArchiver archiveRootObject:self.internalCatchLog toFile:[self itemArchivePath]];
}

- (NSMutableArray *)loadSavedLog {
    NSMutableArray *savedItems = [NSKeyedUnarchiver unarchiveObjectWithFile:[self itemArchivePath]];
    if (savedItems) {
        return savedItems;
    } else {
        return [[NSMutableArray alloc] init];
    }
}

- (NSString *)itemArchivePath {
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    return [documentDirectory stringByAppendingPathComponent:@"troutr_catches.archive"];
}

- (void)sortLog {
    if (self.internalCatchLog) {
        self.internalCatchLog = [[self.internalCatchLog sortedArrayUsingComparator:^NSComparisonResult(TRCatch *catch1, TRCatch *catch2) {
            return [catch2.dateCreated compare:catch1.dateCreated];
        }] mutableCopy];
    }
}

@end
