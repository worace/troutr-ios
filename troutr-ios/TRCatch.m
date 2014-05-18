//
//  TRCatch.m
//  troutr-ios
//
//  Created by Horace Williams on 5/13/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "TRCatch.h"
#import "TRImageStore.h"

@implementation TRCatch
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.species forKey:@"species"];
    [aCoder encodeObject:self.fly forKey:@"fly"];
    [aCoder encodeObject:self.uid forKey:@"uid"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeObject:self.dateCreated forKey:@"dateCreated"];
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _species = [aDecoder decodeObjectForKey:@"species"];
        _fly = [aDecoder decodeObjectForKey:@"fly"];
        _uid = [aDecoder decodeObjectForKey:@"uid"];
        _location = [aDecoder decodeObjectForKey:@"location"];
        _dateCreated = [aDecoder decodeObjectForKey:@"dateCreated"];
    }
    return self;
}
- (void)setImage:(UIImage *)image {
    [[TRImageStore sharedStore] setImage:image forKey:self.uid];
}

- (UIImage *)image {
    return [[TRImageStore sharedStore] imageForKey:self.uid];
}

- (NSString *)uid {
    if (!_uid) {
        _uid = [[[NSUUID alloc] init] UUIDString];
    }
    return _uid;
}
@end
