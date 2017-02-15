//
//  ASClipPlayerViewController.m
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/13/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import "ASClipPlayerViewController.h"

#import "ASPositionFlagButton.h"
#import <ReactiveObjC.h>
#import "NSDate+as.h"
#import "ASClip.h"

@interface ASClipPlayerViewController ()

@property(nonatomic, weak) IBOutlet UISlider *playerSlider;
@property(nonatomic, weak) IBOutlet UILabel *startTimeLabel;
@property(nonatomic, weak) IBOutlet UILabel *endTimeLabel;

@property(nonatomic, readwrite) BOOL isPanning;
@property(nonatomic, readwrite) BOOL isClipEditing;

@end

@implementation ASClipPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.startPositionButton.isStart = YES;
    self.startPositionButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    self.endPositionButton.isStart = NO;
    self.endPositionButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    self.startPositionButton.playerSlider = self.playerSlider;
    self.endPositionButton.playerSlider = self.playerSlider;
    self.playerSlider.value = 0.0;

    @weakify(self);
    [[RACObserve(self, track) distinctUntilChanged] subscribeNext:^(MPMediaItem * track) {
        @strongify(self);
        self.startPositionButton.totalDuration = track.playbackDuration;
        self.endPositionButton.totalDuration = track.playbackDuration;
    }];
    [[RACObserve(self, currentClip) distinctUntilChanged] subscribeNext:^(ASClip * clip) {
        @strongify(self);
        self.startPositionButton.hidden = !clip;
        self.endPositionButton.hidden = !clip;
    }];
    [[RACObserve(self.playerSlider, value) distinctUntilChanged] subscribeNext:^(NSNumber * value) {
        @strongify(self);
        self.startTimeLabel.text = [NSDate formatTimeInterval:value.floatValue*self.track.playbackDuration];
        self.currentPlaytimeFraction = value.floatValue;
    }];
    [[RACObserve(self, isClipEditing) distinctUntilChanged] subscribeNext:^(NSNumber * isEditing) {
        @strongify(self);
        
        self.startPositionButton.enabled = isEditing.boolValue;
        self.endPositionButton.enabled = isEditing.boolValue;
        self.playerSlider.enabled = !isEditing.boolValue;
        self.startPositionButton.enablePlay = isEditing.boolValue;
        self.endPositionButton.enablePlay = isEditing.boolValue;
    }];
    [[RACObserve(self, startButtonPreviewing) distinctUntilChanged] subscribeNext:^(NSNumber * startButtonPreviewing) {
        @strongify(self);
        if (self.isClipEditing) {
            self.endPositionButton.enabled = !startButtonPreviewing.boolValue;
        }
    }];
    [[RACObserve(self, endButtonPreviewing) distinctUntilChanged] subscribeNext:^(NSNumber * endButtonPreviewing) {
        @strongify(self);
        if (self.isClipEditing) {
            self.startPositionButton.enabled = !endButtonPreviewing.boolValue;
        }
    }];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isClipInEditMode:) name:@"asIsClipEditing" object:nil];
}

-  (void)isClipInEditMode:(NSNotification *)notification {
    self.isClipEditing = ((NSNumber *)notification.object).boolValue;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setCurrentClip:(ASClip *)currentClip {
    _currentClip = currentClip;
    if (currentClip) {
        self.startPositionButton.timeInterval = self.currentClip.startTime;
        self.playerSlider.value = (self.currentClip.startTime/self.track.playbackDuration);
        self.endPositionButton.timeInterval = self.currentClip.endTime;
    } else {
        self.startPositionButton.timeInterval = 0.0;
        self.playerSlider.value = 0.0;
        self.endPositionButton.timeInterval = self.track.playbackDuration;
    }
}

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    [self.playerSlider setValue:(currentPlaybackTime/self.track.playbackDuration)];
    self.startTimeLabel.text = [NSDate formatTimeInterval:currentPlaybackTime];
}

- (NSTimeInterval)currentPlaybackTime {
    return self.playerSlider.value * self.track.playbackDuration;
}

- (IBAction)playerSliderValueChanged:(UISlider *)playerSlider {
    self.isPanning = YES;
    NSTimeInterval location = playerSlider.value*self.track.playbackDuration;
    if (location < self.startPositionButton.timeInterval) {
        [self.playerSlider setValue:(self.startPositionButton.timeInterval/self.track.playbackDuration)];
    }
    if (location > self.endPositionButton.timeInterval) {
        [self.playerSlider setValue:(self.endPositionButton.timeInterval/self.track.playbackDuration)];
    }
    self.startTimeLabel.text = [NSDate formatTimeInterval:playerSlider.value*self.track.playbackDuration];
}

- (IBAction)playerSliderPanningDidEnd {
    self.isPanning = NO;
}

- (void)setTrack:(MPMediaItem *)track {
    _track = track;
    self.startTimeLabel.text = [NSDate formatTimeInterval:0.0];
    self.endTimeLabel.text = [NSDate formatTimeInterval:self.track.playbackDuration];
}

-(IBAction)moveStartPositionButtonWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer {

    CGPoint touchLocation = [panGestureRecognizer locationInView:self.view];

    if(panGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        [self.view bringSubviewToFront:self.startPositionButton];
        return;
    }
    if (touchLocation.x > (self.endPositionButton.center.x - self.endPositionButton.bounds.size.width*0.5)) {
        touchLocation.x = (self.endPositionButton.center.x - self.endPositionButton.bounds.size.width*0.5);
    }
    [self.startPositionButton moveCenterX:touchLocation.x];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"asClipStartTimeChanged" object:@(self.startPositionButton.timeInterval)];
}

- (IBAction)moveEndPositionButtonWithGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer{

    CGPoint touchLocation = [panGestureRecognizer locationInView:self.view];

    if(panGestureRecognizer.state == UIGestureRecognizerStateBegan)
    {
        [self.view bringSubviewToFront:self.endPositionButton];
        return;
    }
    if (touchLocation.x < (self.startPositionButton.center.x + self.startPositionButton.bounds.size.width*0.5)) {
        touchLocation.x = (self.startPositionButton.center.x + self.startPositionButton.bounds.size.width*0.5);
    }
    [self.endPositionButton moveCenterX:touchLocation.x];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"asClipEndTimeChanged" object:@(self.endPositionButton.timeInterval)];
}

- (IBAction)tapStartPositionButtonWithGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    self.startPositionButton.selected = !self.startPositionButton.selected;
}

- (IBAction)tapEndPositionButtonWithGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    self.endPositionButton.selected = !self.endPositionButton.selected;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
