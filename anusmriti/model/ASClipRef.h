//
//  ASClipRef.h
//  anusmriti
//
//  Created by Rammohan Vangapalli on 2/2/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import "ASItem.h"

@interface ASClipRef : ASItem

@property (nonatomic, copy) NSString *clipId;
@property (nonatomic, readwrite) NSUInteger repeatCount;

- (instancetype)initWithClipId:(NSString *)clipId;

- (instancetype)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
