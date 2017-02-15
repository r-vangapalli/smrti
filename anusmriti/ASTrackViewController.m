#import "ASTrackViewController.h"

#import <ReactiveObjC.h>
#import "NSDate+as.h"
#import "ASClipPlayerViewController.h"
#import "ASClipListViewController.h"
#import "ASAudioPlayerController.h"
#import "ASPositionFlagButton.h"
#import "ASClipRef.h"

@interface ASTrackViewController () <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>

@property(nonatomic, weak) IBOutlet UITableView *clipListTableView;
@property(nonatomic, weak) IBOutlet UITextView *lyricsTextView;
@property(nonatomic, weak) IBOutlet UIView *textContainerView;

@property(nonatomic, weak) IBOutlet UIButton *editClipListButton;
@property(nonatomic, weak) IBOutlet UIButton *addClipListButton;

@property(nonatomic, weak) IBOutlet UIView *controlsView;
@property(nonatomic, weak) IBOutlet UIButton *loopButton;
@property(nonatomic, weak) IBOutlet UIButton *leftButton;
@property(nonatomic, weak) IBOutlet UIButton *playPauseButton;
@property(nonatomic, weak) IBOutlet UIButton *rightButton;
@property(nonatomic, weak) IBOutlet UIButton *shuffleButton;
@property(nonatomic, weak) IBOutlet UITextField *titleLabel;

@property(nonatomic, weak) IBOutlet UIView *mpVolumeViewParentView;

@property(nonatomic, weak) ASAudioPlayerController *playerController;

@property(nonatomic, weak) ASClipPlayerViewController *clipPlayerViewController;
@property(nonatomic, weak) ASClipListViewController *clipTableViewController;

@property(nonatomic, strong) NSTimer *timer;
@property(nonatomic, readwrite) BOOL isClipEditing;
@property(nonatomic, readwrite) float textViewScrollOffset;
@property(nonatomic, readwrite) float textViewScrollOffsetY;
@property(nonatomic, readwrite) BOOL textViewTouchOn;

@property(nonatomic, strong) ASClipList *currentClipList;
@property(nonatomic, strong) ASClipRef * selectedClipRef;
@property(nonatomic, strong) ASClip * selectedClip;
@property(nonatomic, readwrite) NSInteger selectedClipRepeatCount;
@property(nonatomic, readwrite) BOOL isCurrentClipListPlaying;

@end

@implementation ASTrackViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    MPVolumeView *myVolumeView = [[MPVolumeView alloc] initWithFrame: self.mpVolumeViewParentView.bounds];
    myVolumeView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.mpVolumeViewParentView addSubview: myVolumeView];
    self.playerController = [ASAudioPlayerController sharedInstance];
    self.lyricsTextView.delegate = self;
    self.self.textViewScrollOffset = 0.0;

    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(timedJob) userInfo:nil repeats:YES];
    [self.timer fire];

    @weakify(self);
    [[RACObserve(self, selectedClipRef) distinctUntilChanged] subscribeNext:^(ASClipRef * clipRef) {
        @strongify(self);
        self.selectedClip = [self.currentClipList clipForClipRef:clipRef];
    }];
    [[RACObserve(self, selectedClip) distinctUntilChanged] subscribeNext:^(ASClip * clip) {
        @strongify(self);
        self.leftButton.enabled = !!clip;
        self.playPauseButton.enabled = !!clip;
        self.rightButton.enabled = !!clip;
    }];
    [[RACObserve(self, clipPlayerViewController.currentPlaytimeFraction) distinctUntilChanged] subscribeNext:^(NSNumber * playtimeFraction) {
        @strongify(self);
        if (!self.textViewTouchOn) {
            [self.lyricsTextView setContentOffset:CGPointMake(0, self.lyricsTextView.contentSize.height*playtimeFraction.floatValue + self.textViewScrollOffset) animated:YES];
        }
    }];
    [[RACObserve(self, playerController.playbackState) distinctUntilChanged] subscribeNext:^(NSNumber * playbackState) {
        @strongify(self);
        MPMusicPlaybackState ps = (MPMusicPlaybackState)playbackState.integerValue;
        switch (ps) {
            case MPMusicPlaybackStatePlaying:
                self.playPauseButton.selected = YES;
                break;
            default:
                self.playPauseButton.selected = NO;
                break;
        }
    }];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clipRefDidSelect:) name:@"asClipRefSelected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clipRefDidUnselect:) name:@"asClipRefUnselected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isClipInEditMode:) name:@"asIsClipEditing" object:nil];
}

-  (void)isClipInEditMode:(NSNotification *)notification {
    self.isClipEditing = ((NSNumber *)notification.object).boolValue;
    [self.playerController stop];
    self.isCurrentClipListPlaying = NO;
    [self.playerController setClip:self.selectedClip];
    [self.clipPlayerViewController setCurrentClip:self.selectedClip];
    if (self.isClipEditing) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clipStartTimeDidChange:) name:@"asClipStartTimeChanged" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clipEndTimeDidChange:) name:@"asClipEndTimeChanged" object:nil];
    } else {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"asClipStartTimeChanged" object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:@"asClipEndTimeChanged" object:nil];
    }
}

- (void)clipStartTimeDidChange:(NSNotification *)notification {
    if (self.isClipEditing) {
        self.selectedClip.startTime = ((NSNumber *)notification.object).floatValue;
        [self.clipTableViewController refresh];
    }
}

- (void)clipEndTimeDidChange:(NSNotification *)notification {
    if (self.isClipEditing) {
        self.selectedClip.endTime = ((NSNumber *)notification.object).floatValue;
        [self.clipTableViewController refresh];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSDictionary *attribs = @{ NSForegroundColorAttributeName: [UIColor redColor], NSFontAttributeName: self.self.titleLabel.font };
    NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:self.track.name attributes:attribs];
    NSRange domainPrefixRange = NSMakeRange(0, 1);
    [attributedText setAttributes:@{ NSForegroundColorAttributeName:[UIColor orangeColor] }
                            range:domainPrefixRange];
    self.titleLabel.attributedText = attributedText;

    self.lyricsTextView.text = self.track.mediaItem.lyrics;
    UIImage *image =  [self.track.mediaItem.artwork imageWithSize:self.textContainerView.bounds.size];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = self.lyricsTextView.frame;
    imageView.layer.opacity = self.lyricsTextView.text.length < 10 ? 1.0 : 0.1;
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.textContainerView addSubview:imageView];
    [self.textContainerView sendSubviewToBack:imageView];
    for (UIViewController *controller in self.childViewControllers) {
        if ([controller isKindOfClass:[ASClipPlayerViewController class]]) {
            self.clipPlayerViewController = (ASClipPlayerViewController *)controller;
            self.clipPlayerViewController.track = self.track.mediaItem;
        } else if ([controller isKindOfClass:[ASClipListViewController class]]) {
            self.clipTableViewController = (ASClipListViewController *)controller;
        }
    }
    self.playerController.mediaItem = self.track.mediaItem;
    [self.textContainerView bringSubviewToFront:imageView];

    @weakify(self);
    [[RACObserve(self.clipPlayerViewController.startPositionButton, selected) distinctUntilChanged] subscribeNext:^(NSNumber  * selected) {
        @strongify(self);
        if (selected.boolValue) {
            [self.playerController playFrom:self.clipPlayerViewController.startPositionButton.timeInterval];
        } else {
            [self.playerController stop];
        }
        self.clipPlayerViewController.startButtonPreviewing = selected.boolValue;
        [self disableControls:selected.boolValue];
    }];
    [[RACObserve(self.clipPlayerViewController.endPositionButton, selected) distinctUntilChanged] subscribeNext:^(NSNumber  * selected) {
        @strongify(self);
        if (selected.boolValue) {
            [self.playerController playFrom:self.clipPlayerViewController.endPositionButton.timeInterval];
        } else {
            [self.playerController stop];
        }
        self.clipPlayerViewController.endButtonPreviewing = selected.boolValue;
        [self disableControls:selected.boolValue];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.isCurrentClipListPlaying = NO;
    [self.playerController stop];
}

- (void)disableControls:(BOOL)disable {
//    self.leftButton.enabled = !disable;
    self.playPauseButton.enabled = !disable;
//    self.rightButton.enabled = !disable;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    NSLog(@"%@", segue);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)timedJob {
    if (self.playerController.playbackState == MPMusicPlaybackStatePlaying) {
        if (self.clipPlayerViewController.startButtonPreviewing) {
            self.clipPlayerViewController.startPositionButton.timeInterval = self.playerController.currentPlaybackTime;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"asClipStartTimeChanged" object:@(self.playerController.currentPlaybackTime)];
        } else if(self.clipPlayerViewController.endButtonPreviewing) {
            self.clipPlayerViewController.endPositionButton.timeInterval = self.playerController.currentPlaybackTime;
            [[NSNotificationCenter defaultCenter] postNotificationName:@"asClipEndTimeChanged" object:@(self.playerController.currentPlaybackTime)];
        } else {
            self.clipPlayerViewController.currentPlaybackTime = self.playerController.currentPlaybackTime;
            if (self.playerController.currentPlaybackTime >= self.selectedClip.endTime) {
                if (!self.isClipEditing) {
                    [self.playerController stop];
                    self.clipPlayerViewController.currentPlaybackTime = self.selectedClip.startTime;
                }
            }
        }
    } else if(self.playerController.playbackState == MPMusicPlaybackStateStopped) {
        if (self.isCurrentClipListPlaying) {
            self.selectedClipRepeatCount--;
            if (self.selectedClipRepeatCount < 1) {
                if([self.currentClipList nextClipRef:self.selectedClipRef]) {
                    [self.clipTableViewController selectNextClip];
                } else {
                    self.isCurrentClipListPlaying = NO;
                    self.selectedClipRef = nil;
                    self.selectedClipRepeatCount = 0;
                    [self.clipTableViewController clearSelection];
                    [self.clipTableViewController selectNextClip];
                }
            } else {
                [self.playerController playClip:self.selectedClip];
            }
        }
    }
}

- (void)clipRefDidSelect:(NSNotification *)notification {
    self.selectedClipRef = (ASClipRef *)notification.object;
    self.selectedClipRepeatCount = [self.currentClipList repeatCountForClipRefId:self.selectedClipRef.itemId];
    self.clipPlayerViewController.currentClip = self.selectedClip;
    [self.playerController stop];
    if (self.isCurrentClipListPlaying) {
        [self playPauseButtonPressed:nil];
    }
}

- (void)clipRefDidUnselect:(NSNotification *)notification {
    self.selectedClipRef = nil;
    self.clipPlayerViewController.currentClip = self.selectedClip;
    [self.playerController stop];
}

- (IBAction)addClipList:(UIButton *)addClipButton {
    [self.track createAndAddNewClipList];
    [self.clipListTableView reloadData];
}

- (IBAction)editClipList:(UIButton *)editClipButton {
    if (self.clipListTableView.isEditing) {
        [self.clipListTableView setEditing:NO animated:YES];
    } else {
        [self.clipListTableView setEditing:YES animated:YES];
    }
    NSIndexPath *selectedPath = [self.clipListTableView indexPathForSelectedRow];
    self.editClipListButton.selected = self.clipListTableView.isEditing;
    if (selectedPath) {
        [self.clipListTableView selectRowAtIndexPath:selectedPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
    }
}

- (IBAction)loopButtonPressed:(UIButton *)loopButton {
    NSLog(@"loopButtonPressed");
}

- (IBAction)playPauseButtonPressed:(UIButton *)playPauseButton {
    switch (self.playerController.playbackState) {
        case MPMusicPlaybackStatePaused:
            [self.playerController play];
            break;
        case MPMusicPlaybackStatePlaying:
            [self.playerController pause];
            break;
        case MPMusicPlaybackStateStopped:
        case MPMusicPlaybackStateInterrupted:
        {
            if (self.currentClipList) {
                if (self.selectedClip) {
                    self.selectedClipRepeatCount = [self.currentClipList repeatCountForClipRefId:self.selectedClipRef.itemId];
                    if (self.selectedClipRepeatCount > 0) {
                        self.clipPlayerViewController.currentClip = self.selectedClip;
                        [self.playerController playClip:self.selectedClip];
                    } else {
                        self.isCurrentClipListPlaying = YES;
                        [self.clipTableViewController selectNextClip];
                    }
                } else {
                    [self.clipTableViewController selectNextClip];
                }
                self.isCurrentClipListPlaying = YES;
            }
        }
            break;
        default:
            break;
    }
}

- (IBAction)leftButtonPressed:(UIButton *)leftButton {
    [self.playerController skip:NO];
}

- (IBAction)rightpButtonPressed:(UIButton *)rightpButton {
    [self.playerController skip:YES];
}

- (IBAction)shuffleButtonPressed:(UIButton *)shuffleButton {
    shuffleButton.selected = !shuffleButton.selected;
    NSLog(@"shuffleButtonPressed");
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.track.clipListCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"asClipListTableCell" forIndexPath:indexPath];
    
    ASClipList* clipList = [self.track clipListAtIndex:indexPath.item];
    cell.textLabel.text = clipList.name;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.track deleteClipAtIndex:indexPath.item];
        [self.clipListTableView reloadData];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
     [self.track moveClipListFrom:(NSUInteger)fromIndexPath.item to:(NSUInteger)toIndexPath.item];
     [self.clipListTableView reloadData];
 }

 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 30.0;
}

#pragma mark - Table view delegate
 - (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
     self.currentClipList = [self.track clipListAtIndex:indexPath.item];
     [[NSNotificationCenter defaultCenter] postNotificationName:@"asClipListSelected" object:self.currentClipList];

 }

#pragma mark - scoll view delegate methods

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.textViewScrollOffsetY = scrollView.contentOffset.y;
    self.textViewTouchOn = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        [self touchScrollEnded:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self touchScrollEnded:scrollView];
}

- (void)touchScrollEnded:(UIScrollView *)scrollView {
    self.textViewScrollOffset += (scrollView.contentOffset.y - self.textViewScrollOffsetY);
    self.textViewTouchOn = NO;
}

@end
