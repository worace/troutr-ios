//
//  TRImageStore.m
//  troutr-ios
//
//  Created by Horace Williams on 5/14/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "TRImageStore.h"

@interface TRImageStore ()
@property (nonatomic, strong)NSMutableDictionary *imageDictionary;
@end

@implementation TRImageStore
+ (instancetype)sharedStore {
    static TRImageStore *sharedStore;
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
        _imageDictionary = [[NSMutableDictionary alloc] init];
    }
    
    [self registerForMemoryNotif];
    return self;
}

- (UIImage *)imageForKey:(NSString *)key {
    UIImage *image = self.imageDictionary[key];
    if (!image) {
        image = [UIImage imageWithContentsOfFile:[self imagePathForKey:key]];
        if (image) {
            self.imageDictionary[key] = image;
        } else {
            NSLog(@"error unable to find %@", [self imagePathForKey:key]);
        }
    }
    return image;
}

- (void)setImage:(UIImage *)image forKey:(NSString *)key {
    self.imageDictionary[key] = image;
    NSString *imagePath = [self imagePathForKey:key];
    NSData *data = UIImageJPEGRepresentation(image, 0.5);
    [data writeToFile:imagePath atomically:YES];
}

- (NSString *)imagePathForKey:(NSString *)key {
    NSArray *documentDirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDir = [documentDirs firstObject];
    return [documentDir stringByAppendingPathComponent:key];
}

- (void)deleteImageForKey:(NSString *)key {
    if (!key) { return; }
    [self.imageDictionary removeObjectForKey:key];
    NSString *imagePath = [self imagePathForKey:key];
    [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
}

- (void)clearCache:(id)sender {
    [self.imageDictionary removeAllObjects];
}

- (void)registerForMemoryNotif {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(clearCache:)
                                                 name:UIApplicationDidReceiveMemoryWarningNotification
                                               object:nil];
}


@end
