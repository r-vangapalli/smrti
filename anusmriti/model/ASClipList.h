//
//  ASClipList.h
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/12/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import "ASItem.h"
#import "ASMasterClipList.h"

@class ASClipRef;
@class ASClip;

@interface ASClipList : ASItem

@property(nonatomic, readonly) NSUInteger clipRefCount;
@property(nonatomic, weak) ASMasterClipList *masterClipList;

- (instancetype)initWithId:(NSString *)itemId name:(NSString *)name masterClipList:(ASMasterClipList *)masterClipList;

- (NSUInteger)indexOfClipRef:(ASClipRef *)clipRef;
- (ASClipRef *)clipRefAtIndex:(NSUInteger)index;
- (void)addClipRef:(ASClipRef *)clipRef;
- (void)deleteClipRefAt:(NSUInteger)index;
- (void)setRepeatCount:(NSUInteger)repeatCount forClipRefId:(NSString *)clipRefId;
- (NSUInteger)repeatCountForClipRefId:(NSString *)clipRefId;
- (ASClipRef *)nextClipRef:(ASClipRef *)currentClip;
- (ASClip *)clipForClipRef:(ASClipRef *)clipRef;
- (void)moveClipRefFromLocation:(NSUInteger)fromIndex toLocation:(NSUInteger)toIndex;
- (void)cloneClipRefAt:(NSUInteger)clipRefIndex;

- (instancetype)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
