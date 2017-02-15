//
//  ASUtils.h
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/12/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface ASUtils : NSObject

+ (NSString *)toString:(MPMediaEntityPersistentID) mediaPersistentId;
+ (MPMediaEntityPersistentID)fromString:(NSString *)mediaPersistentId;

@end
