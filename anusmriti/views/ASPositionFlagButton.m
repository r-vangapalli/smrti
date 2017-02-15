//
//  ASPositionFlagButton.m
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/13/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import "ASPositionFlagButton.h"

#import <ReactiveObjC.h>
#import "NSDate+as.h"

@interface ASPositionFlagButton ()

@property(nonatomic, strong) UILabel *timeLabel;
@property(nonatomic, readwrite) CGFloat offset;
@property(nonatomic, strong) UIImage *imageNormal;
@property(nonatomic, strong) UIImage *imageSelected;

@end

@implementation ASPositionFlagButton

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width*2.0, 20)];
        [self addSubview:_timeLabel];
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.textColor = [UIColor greenColor];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.font = [_timeLabel.font fontWithSize:12];
        _timeLabel.adjustsFontSizeToFitWidth = YES;
        _imageNormal = [UIImage imageNamed:@"position-play"];
        _imageSelected = [UIImage imageNamed:@"position-pause"];

        @weakify(self);
        [[RACObserve(self, enablePlay) distinctUntilChanged] subscribeNext:^(NSNumber * isEnable) {
            @strongify(self);
            if (isEnable.boolValue) {
                [self setImage:self.imageNormal forState:UIControlStateNormal];
                [self setImage:self.imageSelected forState:UIControlStateSelected];
            } else {
                [self setImage:nil forState:UIControlStateNormal];
                [self setImage:nil forState:UIControlStateSelected];
            }
        }];

    }
    return self;
}

- (void)setIsStart:(BOOL)isStart {
    _isStart = isStart;
    self.timeLabel.textAlignment = isStart ? NSTextAlignmentRight : NSTextAlignmentLeft;
    if (isStart) {
        self.timeLabel.center = CGPointMake(self.bounds.origin.x, self.timeLabel.center.y);
    } else {
        self.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 5);
    }
    self.timeLabel.center = CGPointMake(self.timeLabel.center.x, isStart ? self.timeLabel.center.y : self.timeLabel.center.y + self.timeLabel.bounds.size.height*0.5);
}

- (void)setTimeInterval:(NSTimeInterval)timeInterval {
    _timeInterval = timeInterval;
    self.timeLabel.text = [NSDate formatTimeInterval:timeInterval];
    [self refreshCenter];
}

- (CGFloat)refX {
    return (self.center.x + self.offset);
}

- (void)moveCenterX:(CGFloat)xCenterNew {
    if (xCenterNew < self.playerSlider.frame.origin.x) {
        xCenterNew = self.playerSlider.frame.origin.x;
    } else if(xCenterNew > (self.playerSlider.frame.origin.x + self.playerSlider.bounds.size.width)) {
        xCenterNew = (self.playerSlider.frame.origin.x + self.playerSlider.bounds.size.width);
    }
    self.timeInterval = (xCenterNew - self.playerSlider.frame.origin.x)*(self.totalDuration/self.playerSlider.bounds.size.width);
}

- (CGFloat)offset {
    return self.bounds.size.width * (self.isStart ? -0.5 : 0.5);
}

// private methods
- (void)refreshCenter {
    if (self.totalDuration < 0.001) {
        return;
    }
    //x location of button ref loc w.r.t the slider
    CGFloat xLocOnSlider = self.playerSlider.frame.origin.x + self.playerSlider.bounds.size.width * self.timeInterval/self.totalDuration;
    self.center = CGPointMake(xLocOnSlider + self.offset, self.center.y);
}

@end
