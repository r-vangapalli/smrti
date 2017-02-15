//
//  ASTrack.h
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/11/17.
//  Copyright © 2017 ram. All rights reserved.
//
#import "ASItem.h"

#import <MediaPlayer/MediaPlayer.h>
#import "ASMasterClipList.h"
#import "ASClipList.h"
#import "ASTrackProperties.h"

#import <Foundation/Foundation.h>

@interface ASTrack : ASItem

@property(nonatomic, strong) MPMediaItem* mediaItem;
@property(nonatomic, readonly) ASTrackProperties *configProperties;
@property(nonatomic, readonly) NSUInteger clipListCount;;

- (instancetype)initWithMediaItem:(MPMediaItem *) mediaItem;

- (void)configWithProperties:(ASTrackProperties *)properties;

- (void)createAndAddNewClipList;

- (ASClipList *)clipListAtIndex:(NSUInteger)index;

- (void)addClipList:(ASClipList *)clipList;
- (void)deleteClipAtIndex:(NSUInteger)index;
- (void)moveClipListFrom:(NSUInteger)fromIndex to:(NSUInteger)toIndex;
- (instancetype)initWithCoder:(NSCoder *)decoder;
- (void)encodeWithCoder:(NSCoder *)encoder;

@end
