//
//  ASMasterClipList.m
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/12/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import "ASMasterClipList.h"

@interface ASMasterClipList()

@property(nonatomic, strong) NSMutableArray<ASClip *> *clipList;

@end

@implementation ASMasterClipList

- (instancetype)init {
    self = [super initWithId:[[NSUUID UUID] UUIDString] name:@"Master"];
    if (self) {
        _clipList = [NSMutableArray array];
    }
    return self;
}

- (NSArray *)clipLists {
    return [self.clipList copy];
}

- (NSUInteger)clipCount {
    return  self.clipList.count;
}

- (ASClip *)clipAtIndex:(NSUInteger)index {
    return [self.clipList objectAtIndex:index];
}

- (void)addClip:(ASClip *)clip {
    NSUInteger index = [self indexOfClipWithId:clip.itemId];
    if (index != NSNotFound) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"Clip with same id already exists in the list" userInfo:nil];
    }
    [self.clipList addObject:clip];
}

- (ASClip *)clipById:(NSString *)itemId {
    NSUInteger index = [self indexOfClipWithId:itemId];
    return (index != NSNotFound) ? self.clipList[index] : nil;
}

- (void)updateClip:(ASClip *)clip {

    ASClip *existing = [self clipById:clip.itemId];
    if (existing) {
        existing.name = clip.name;
        existing.startTime = clip.startTime;
        existing.endTime = clip.endTime;
    }
}

- (void)deleteClipById:(NSString *)itemId {
    ASClip *existing = [self clipById:itemId];
    if (existing) {
        [self.clipList removeObject:existing];
    }
}

- (BOOL)hasClipWithId:(NSString *)itemId {
    NSUInteger index = [self indexOfClipWithId:itemId];
    return (index != NSNotFound);
}

- (NSUInteger)indexOfClipWithId:(NSString *)itemId {
    NSUInteger index = [self.clipList indexOfObjectPassingTest:^BOOL(ASClip *  _Nonnull clip, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([clip.itemId isEqualToString:itemId]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    return index;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        _clipList = [decoder decodeObjectForKey:@"clipList"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.clipList forKey:@"clipList"];
}

@end
