//
//  ASClipList.m
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/12/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import "ASClipList.h"

#import "ASClip.h"
#import "ASClipRef.h"
#import "NSMutableArray+move.h"

@interface ASClipList()

@property(nonatomic, strong) NSMutableArray<ASClipRef *> *clipRefs;

@end

@implementation ASClipList

- (instancetype)initWithId:(NSString *)itemId name:(NSString *)name masterClipList:(ASMasterClipList *)masterClipList {
    self = [super initWithId:itemId name:name];
    if (self) {
        _masterClipList = masterClipList;
        _clipRefs = [NSMutableArray arrayWithCapacity:_masterClipList.clipCount];
        for (ASClip *clip in self.masterClipList.clipLists) {
            [_clipRefs addObject:[[ASClipRef alloc] initWithClipId:clip.itemId]];
        }
    }
    return self;
}

- (NSUInteger)clipRefCount {
    return self.clipRefs.count;
}

- (NSUInteger)indexOfClipRef:(ASClipRef *)clipRef {
    return [self indexOfClipRefById:clipRef.itemId];
}

- (NSUInteger)indexOfClipRefById:(NSString *)clipRefId {
    NSUInteger index = [self.clipRefs indexOfObjectPassingTest:^BOOL(ASClipRef * clipRef, NSUInteger index, BOOL *stop) {
        if ([clipRefId isEqualToString:clipRef.itemId]) {
            *stop = YES;
            return YES;
        }
        return NO;
    }];
    return index;
}

- (ASClipRef *)clipRefAtIndex:(NSUInteger)index {
    if (index >= self.clipRefs.count) {
        return nil;
    }
    return self.clipRefs[index];
}

- (void)addClipRef:(ASClipRef *)clipRef {
    [self.clipRefs addObject:clipRef];
}

- (void)deleteClipRefAt:(NSUInteger)index {
        [self.clipRefs removeObjectAtIndex:index];
}

- (void)setRepeatCount:(NSUInteger)repeatCount forClipRefId:(NSString *)clipRefId {
    NSUInteger index = [self indexOfClipRefById:clipRefId];
    if (index != NSNotFound) {
        ASClipRef * clipRef = [self clipRefAtIndex:index];
        clipRef.repeatCount = repeatCount;
    }
}

- (NSUInteger)repeatCountForClipRefId:(NSString *)clipRefId {
    NSUInteger index = [self indexOfClipRefById:clipRefId];
    if (index != NSNotFound) {
        ASClipRef * clipRef = [self clipRefAtIndex:index];
        return clipRef.repeatCount;
    }
    return 0;
}

- (ASClipRef *)nextClipRef:(ASClipRef *)currentClipRef {
    if (currentClipRef == nil) {
        return [self clipRefAtIndex:0];
    }
    NSUInteger index = [self indexOfClipRef:currentClipRef];
    if (NSNotFound != index) {
        return [self clipRefAtIndex:index + 1];
    }
    return nil;
}

- (ASClip *)clipForClipRef:(ASClipRef *)clipRef {
    if (clipRef) {
        return [self.masterClipList clipById:clipRef.clipId];
    }
    return nil;
}

- (void)moveClipRefFromLocation:(NSUInteger)fromIndex toLocation:(NSUInteger)toIndex {
    [self.clipRefs moveObjectAtIndex:fromIndex toIndex:toIndex];
}

- (void)cloneClipRefAt:(NSUInteger)clipRefIndex {
    ASClipRef *clipRef = self.clipRefs[clipRefIndex];
    ASClipRef *clipRefNew = [[ASClipRef alloc] initWithClipId:clipRef.clipId];
    clipRefNew.repeatCount = clipRef.repeatCount;
    [self.clipRefs insertObject:clipRefNew atIndex:clipRefIndex+1];
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        _clipRefs = [NSMutableArray arrayWithArray:[decoder decodeObjectForKey:@"clipRefs"]];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.clipRefs forKey:@"clipRefs"];
}
@end
