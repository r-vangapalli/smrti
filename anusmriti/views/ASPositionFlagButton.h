//
//  ASPositionFlagButton.h
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/13/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ASPositionFlagButton : UIButton

@property(nonatomic, weak) UISlider *playerSlider;
@property(nonatomic, readwrite) NSTimeInterval totalDuration;

@property(nonatomic, readwrite) BOOL isStart;
@property(nonatomic, readwrite) BOOL enablePlay;
@property(nonatomic, readwrite) NSTimeInterval timeInterval;
@property(nonatomic, readonly) CGFloat refX;

- (void)moveCenterX:(CGFloat)xCenterNew;

@end
