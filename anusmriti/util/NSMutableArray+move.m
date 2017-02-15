//
//  NSMutableArray+move.m
//  anusmriti
//
//  Created by Rammohan Vangapalli on 2/11/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import "NSMutableArray+move.h"

@implementation NSMutableArray (move)

- (void)moveObjectAtIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    // Optional toIndex adjustment if you think toIndex refers to the position in the array before the move (as per Richard's comment)
    if (fromIndex < toIndex) {
        toIndex--; // Optional
    }

    id object = [self objectAtIndex:fromIndex];
    [self removeObjectAtIndex:fromIndex];
    [self insertObject:object atIndex:toIndex];
}

@end
