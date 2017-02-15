//
//  NSDate+as.m
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/12/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import "NSDate+as.h"

@implementation NSDate (as)

+ (NSString *)formatTimeInterval:(NSTimeInterval)interval {
    NSDateComponentsFormatter *formatter = [[NSDateComponentsFormatter alloc] init];
    formatter.allowedUnits = NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    formatter.zeroFormattingBehavior = NSDateComponentsFormatterZeroFormattingBehaviorDefault;
    return [formatter stringFromTimeInterval:interval];
}

@end
