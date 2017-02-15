//
//  ASTrack.m
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/11/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import "ASTrack.h"

#import "ASClipList.h"
#import "ASUtils.h"
#import "NSMutableArray+move.h"

@interface ASTrack ()

@property(nonatomic, strong) ASMasterClipList *masterClips;
@property(nonatomic, strong) NSMutableArray<ASClipList *> *clipLists;
@property(nonatomic, strong) ASTrackProperties *configProperties;

@end

@implementation ASTrack

- (instancetype)initWithMediaItem:(MPMediaItem *)mediaItem {
    self = [super initWithId:[ASUtils toString:mediaItem.persistentID] name:mediaItem.title];
    if (self) {
        _mediaItem = mediaItem;
    }
    return self;
}

- (void)configWithProperties:(ASTrackProperties *)configProperties {
    if (!self.mediaItem) {
        NSLog(@"A media item must have been set before calling config");
        return;
    }
    self.configProperties = configProperties;
    self.masterClips = [[ASMasterClipList alloc] init];
    float interval = self.mediaItem.playbackDuration/self.configProperties.clipCount;
    for (NSUInteger i=0; i<self.configProperties.clipCount; i++) {
        ASClip *clip = [[ASClip alloc] initWithId:[[NSUUID UUID] UUIDString] name:[NSString stringWithFormat:@"%@ %lu", self.configProperties.clipNamePrefix, (i+1)]];
        clip.startTime = interval*i;
        clip.endTime = interval*(i+1);
        [self.masterClips addClip:clip];
    }
    self.clipLists = [NSMutableArray array];
    for (NSUInteger i=0; i<self.configProperties.clipListCount; i++) {
        [self createAndAddNewClipList];
    }
}

- (void)createAndAddNewClipList {
    NSUInteger index =  self.clipLists.count;
    ASClipList *clipList = [[ASClipList alloc] initWithId:[[NSUUID UUID] UUIDString] name:[NSString stringWithFormat:@"%@ %lu", self.configProperties.clipListNamePrefix, (index+1)] masterClipList:self.masterClips];
    [self addClipList:clipList];
}

- (ASClipList *)clipListAtIndex:(NSUInteger)index {
    return self.clipLists[index];
}

- (NSUInteger)clipListCount {
    return self.clipLists.count;
}

- (void)addClipList:(ASClipList *)clipList {
    NSUInteger index = [self indexOfItemWithId:clipList.itemId];
    if (index == NSNotFound) {
        [self.clipLists addObject:clipList];
    }
}

- (void)deleteClipAtIndex:(NSUInteger)index {
    if (index != NSNotFound) {
        [self.clipLists removeObject:self.clipLists[index]];
    }
}

- (void)moveClipListFrom:(NSUInteger)fromIndex to:(NSUInteger)toIndex {
    [self.clipLists moveObjectAtIndex:fromIndex toIndex:toIndex];

}

// private methods
- (NSUInteger)indexOfItemWithId:(NSString *)itemId {
    NSUInteger index = [self.clipLists indexOfObjectPassingTest:^BOOL(ASClipList *  _Nonnull clip, NSUInteger idx, BOOL * _Nonnull stop) {
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
        _masterClips = [decoder decodeObjectForKey:@"masterClips"];
        _clipLists = [NSMutableArray arrayWithArray:[decoder decodeObjectForKey:@"clipLists"]];
        _configProperties = [decoder decodeObjectForKey:@"configProperties"];

        for (ASClipList *clipList in _clipLists) {
            clipList.masterClipList = _masterClips;
        }
        MPMediaQuery*   query = [MPMediaQuery songsQuery];
        MPMediaPropertyPredicate* pred = [MPMediaPropertyPredicate predicateWithValue:self.itemId forProperty:MPMediaItemPropertyPersistentID];
        [query addFilterPredicate:pred];
        MPMediaItem *mediaItem = [query.items firstObject];
        self.mediaItem = mediaItem;
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:self.masterClips forKey:@"masterClips"];
    [encoder encodeObject:self.clipLists forKey:@"clipLists"];
    [encoder encodeObject:self.configProperties forKey:@"configProperties"];
}

@end
