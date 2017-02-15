//
//  ASItem.h
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/12/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ASItem : NSObject

@property(nonatomic, readonly) NSString *itemId;
@property(nonatomic, strong) NSString *name;

- (instancetype)initWithId:(NSString *)itemId name:(NSString *)name;

- (instancetype)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
