//
//  ASClipPlayerViewController.h
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/13/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>

@class ASPositionFlagButton;
@class ASClip;

@interface ASClipPlayerViewController : UIViewController

@property(nonatomic, weak) IBOutlet ASPositionFlagButton *startPositionButton;
@property(nonatomic, weak) IBOutlet ASPositionFlagButton *endPositionButton;

@property(nonatomic, weak) MPMediaItem *track;
@property(nonatomic, readwrite) NSTimeInterval currentPlaybackTime;
@property(nonatomic, weak) ASClip *currentClip;
@property(nonatomic, readwrite) float currentPlaytimeFraction;;
@property(nonatomic, readwrite) BOOL startButtonPreviewing;
@property(nonatomic, readwrite) BOOL endButtonPreviewing;

@end
