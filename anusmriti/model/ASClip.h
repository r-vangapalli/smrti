//
//  ASClip.h
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/12/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import "ASItem.h"

@interface ASClip : ASItem

@property(nonatomic, readwrite) float startTime;
@property(nonatomic, readwrite) float endTime;

- (instancetype)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
