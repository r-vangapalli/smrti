//
//  ASMasterClipList.h
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/12/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import "ASItem.h"
#import "ASClip.h"

@interface ASMasterClipList : ASItem

@property(nonatomic, readonly) NSUInteger clipCount;
@property(nonatomic, readonly) NSArray<ASClip *> *clipLists;

- (ASClip *)clipAtIndex:(NSUInteger)index;
- (void)addClip:(ASClip *)clip;
- (ASClip *)clipById:(NSString *)itemId;
- (void)updateClip:(ASClip *)clip;
- (void)deleteClipById:(NSString *)itemId;
- (BOOL)hasClipWithId:(NSString *)itemId;
- (NSUInteger)indexOfClipWithId:(NSString *)itemId;

- (instancetype)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
