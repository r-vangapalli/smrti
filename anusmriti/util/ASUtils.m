//
//  ASUtils.m
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/12/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import "ASUtils.h"

@implementation ASUtils

+ (NSString *)toString:(MPMediaEntityPersistentID)mediaItemPersistentId {
    return [NSString stringWithFormat:@"%llu", mediaItemPersistentId];
}

+ (MPMediaEntityPersistentID)fromString:(NSString *)mediaPersistentId {
    return strtoull([mediaPersistentId UTF8String], NULL, 0);
}

@end
