//
//  ASTrackProperties.h
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/27/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASTrackProperties : NSObject

@property(nonatomic, readwrite) NSUInteger clipCount;
@property(nonatomic, readwrite) NSString *clipNamePrefix;
@property(nonatomic, readwrite) NSUInteger clipListCount;
@property(nonatomic, readwrite) NSString *clipListNamePrefix;

- (instancetype)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
