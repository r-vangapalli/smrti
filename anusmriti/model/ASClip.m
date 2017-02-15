//
//  ASClip.m
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/12/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import "ASClip.h"

@implementation ASClip

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        _startTime = [decoder decodeFloatForKey:@"startTime"];
        _endTime = [decoder decodeFloatForKey:@"endTime"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeFloat:self.startTime forKey:@"startTime"];
    [encoder encodeFloat:self.endTime forKey:@"endTime"];
}

@end
