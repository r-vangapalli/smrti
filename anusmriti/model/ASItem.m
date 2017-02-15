//
//  ASItem.m
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/12/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import "ASItem.h"

@interface ASItem ()

@property(nonatomic, strong) NSString *itemId;

@end

@implementation ASItem

- (instancetype)initWithId:(NSString *)itemId name:(NSString *)name {
    self = [super init];
    if (self) {
        _itemId = itemId;
        _name = name;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        _itemId = [decoder decodeObjectForKey:@"itemid"];
        _name = [decoder decodeObjectForKey:@"name"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:self.itemId forKey:@"itemid"];
    [encoder encodeObject:self.name forKey:@"name"];
}

@end
