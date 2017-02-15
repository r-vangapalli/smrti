//
//  ASTrackPropertiesViewController.h
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/26/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASTrackProperties.h"
#import <MediaPlayer/MediaPlayer.h>

@class ASTrackPropertiesViewController;

@protocol ASTrackPropertiesViewControllerDelegate <NSObject>

- (void)trackPropertiesViewController:(ASTrackPropertiesViewController *)trackPropertiesViewController willCloseWithProperties:(ASTrackProperties *)properties;

@end

@interface ASTrackPropertiesViewController : UIViewController

@property(nonatomic, weak) MPMediaItem *mediaItem;

@property(nonatomic, weak)id<ASTrackPropertiesViewControllerDelegate> delegate;

@end
