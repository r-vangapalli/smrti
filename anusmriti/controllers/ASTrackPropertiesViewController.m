//
//  ASTrackPropertiesViewController.m
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/26/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import "ASTrackPropertiesViewController.h"

#import <ReactiveObjC.h>
#import "NSDate+as.h"

@interface ASTrackPropertiesViewController ()

@property(nonatomic, weak) IBOutlet UILabel *trackDurationLabel;
@property(nonatomic, weak) IBOutlet UIStepper *clipCountStepper;
@property(nonatomic, weak) IBOutlet UITextField *clipCount;
@property(nonatomic, weak) IBOutlet UITextField *clipNamePrefix;
@property(nonatomic, weak) IBOutlet UINavigationItem *navItem;

@property(nonatomic, weak) IBOutlet UIStepper *clipListCountStepper;
@property(nonatomic, weak) IBOutlet UITextField *clipListCount;
@property(nonatomic, weak) IBOutlet UITextField *clipListNamePrefix;

@end

@implementation ASTrackPropertiesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    RAC(self, clipCount.text) = [RACObserve(self, clipCountStepper.value) map:^(NSNumber *value) {
        return [NSString stringWithFormat:@"%lu", (long)value.integerValue];
    }];
    RAC(self, clipListCount.text) = [RACObserve(self, clipListCountStepper.value) map:^(NSNumber *value) {
        return [NSString stringWithFormat:@"%lu", (long)value.integerValue];
    }];
    self.navItem.title = self.mediaItem.title;
    self.trackDurationLabel.text = [NSString stringWithFormat:@"Track duration: %@", [NSDate formatTimeInterval:self.mediaItem.playbackDuration]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (IBAction)close {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)ok {
    ASTrackProperties *props = [[ASTrackProperties alloc] init];
    props.clipCount = self.clipCount.text.integerValue;
    props.clipNamePrefix = self.clipNamePrefix.text;
    props.clipListCount = self.clipListCount.text.integerValue;
    props.clipListNamePrefix = self.clipListNamePrefix.text;

    [self.delegate trackPropertiesViewController:self willCloseWithProperties:props];
    [self close];
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
