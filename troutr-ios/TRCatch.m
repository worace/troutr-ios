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
    if (self.image) {
        [[TRImageStore sharedStore] setImage:self.image forKey:self.uid];
    }
    [aCoder encodeObject:self.species forKey:@"species"];
    [aCoder encodeObject:self.fly forKey:@"fly"];
    [aCoder encodeObject:self.uid forKey:@"uid"];
    [aCoder encodeObject:self.location forKey:@"location"];
    [aCoder encodeObject:self.dateCreated forKey:@"dateCreated"];
    [aCoder encodeObject:self.videoAssetURL forKey:@"videoAssetURL"];
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _species = [aDecoder decodeObjectForKey:@"species"];
        _fly = [aDecoder decodeObjectForKey:@"fly"];
        _uid = [aDecoder decodeObjectForKey:@"uid"];
        _location = [aDecoder decodeObjectForKey:@"location"];
        _dateCreated = [aDecoder decodeObjectForKey:@"dateCreated"];
        _videoAssetURL = [aDecoder decodeObjectForKey:@"videoAssetURL"];
    }
    return self;
}

- (UIImage *)image {
    if (!_image) {
        _image = [[TRImageStore sharedStore] imageForKey:self.uid];
    }
    return _image;
}

- (NSDate *)dateCreated {
    if (!_dateCreated) {
        _dateCreated = [NSDate date];
    }
    return _dateCreated;
}

- (NSString *)uid {
    if (!_uid) {
        _uid = [[[NSUUID alloc] init] UUIDString];
    }
    return _uid;
}
@end
