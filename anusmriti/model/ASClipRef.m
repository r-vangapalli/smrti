//
//  ASClipRef.m
//  anusmriti
//
//  Created by Rammohan Vangapalli on 2/2/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import "ASClipRef.h"

@implementation ASClipRef

- (instancetype)initWithClipId:(NSString *)clipId
{
    self = [super initWithId:[[NSUUID UUID] UUIDString] name:@"*"];
    if (self) {
        _repeatCount = 1;
        _clipId = clipId;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        _clipId = [decoder decodeObjectForKey:@"clipId"];
        _repeatCount = [decoder decodeIntegerForKey:@"repeatCount"];

    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.clipId forKey:@"clipId"];
    [encoder encodeInteger:self.repeatCount forKey:@"repeatCount"];
}

@end
