//
//  ASTrackProperties.m
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/27/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import "ASTrackProperties.h"

@implementation ASTrackProperties

- (instancetype)init
{
    self = [super init];
    if (self) {
        _clipCount = 0;
        _clipNamePrefix = @"Clip";
        _clipListCount = 0;
        _clipListNamePrefix = @"Clip List";
    }
    return self;
}


- (instancetype)initWithCoder:(NSCoder *)decoder
{
    if (self) {
        _clipCount = [decoder decodeIntegerForKey:@"clipCount"];
        _clipNamePrefix = [decoder decodeObjectForKey:@"clipNamePrefix"];
        _clipListCount = [decoder decodeIntegerForKey:@"clipListCount"];
        _clipListNamePrefix = [decoder decodeObjectForKey:@"clipListNamePrefix"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeInteger:self.clipCount forKey:@"clipCount"];
    [encoder encodeObject:self.clipNamePrefix forKey:@"clipNamePrefix"];
    [encoder encodeInteger:self.clipListCount forKey:@"clipListCount"];
    [encoder encodeObject:self.clipListNamePrefix forKey:@"clipListNamePrefix"];
}

@end
