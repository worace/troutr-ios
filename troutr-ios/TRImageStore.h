//
//  TRImageStore.h
//  troutr-ios
//
//  Created by Horace Williams on 5/14/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TRImageStore : NSObject
+ (instancetype)sharedStore;
- (void)setImage:(UIImage *)image forKey:(NSString *)key;
- (UIImage *)imageForKey:(NSString *)key;
- (void)deleteImageForKey:(NSString *)key;
@end
