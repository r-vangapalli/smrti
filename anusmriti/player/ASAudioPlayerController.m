#import "ASAudioPlayerController.h"

#import <AVFoundation/AVFoundation.h>
#import "ASClip.h"

@interface NSArray (shuffled)
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSArray *shuffled;
@end


@implementation NSArray (shuffled)

- (NSArray *)shuffled {
	NSMutableArray *tmpArray = [NSMutableArray arrayWithCapacity:[self count]];

	for (id anObject in self) {
		NSUInteger randomPos = arc4random()%([tmpArray count]+1);
		[tmpArray insertObject:anObject atIndex:randomPos];
	}

	return [NSArray arrayWithArray:tmpArray];
}

@end

@interface ASAudioPlayerController ()
@property (copy, nonatomic) NSArray *delegates;
@property (strong, nonatomic) AVPlayer *player;
@property (strong, nonatomic) NSArray *originalQueue;
@property (strong, nonatomic, readwrite) NSArray *queue;
@property (strong, nonatomic, readwrite) MPMediaItem *nowPlayingItem;
@property (nonatomic, readwrite) NSUInteger indexOfNowPlayingItem;
@property (nonatomic) BOOL interrupted;
@property (nonatomic) BOOL isLoadingAsset;
@end


@implementation ASAudioPlayerController

+ (ASAudioPlayerController *)sharedInstance {
    static dispatch_once_t onceQueue;
    static ASAudioPlayerController *instance = nil;
    dispatch_once(&onceQueue, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.indexOfNowPlayingItem = NSNotFound;
        self.delegates = @[];


        // Make sure the system follows our playback status
        AVAudioSession *audioSession = [AVAudioSession sharedInstance];
        NSError *sessionError = nil;
        BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
        if (!success){
            NSLog(@"setCategory error %@", sessionError);
        }
        success = [audioSession setActive:YES error:&sessionError];
        if (!success){
            NSLog(@"setActive error %@", sessionError);
        }
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleInterruption:)
                                                     name: AVAudioSessionInterruptionNotification
                                                   object: [AVAudioSession sharedInstance]];

        // Handle unplugging of headphones
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(handleRouteChange:)
                                                     name: AVAudioSessionRouteChangeNotification
                                                   object: audioSession];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleStateChanged:)
                                                     name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                                                   object:nil];

        // Listen for volume changes
        [[MPMusicPlayerController systemMusicPlayer] beginGeneratingPlaybackNotifications];
    }

    return self;
}
-(void)handleStateChanged:(NSNotification*)notification{
    NSLog(@"%ld", (long)[MPMusicPlayerController systemMusicPlayer].playbackState);
}

-(void)handleRouteChange:(NSNotification*)notification{
    AVAudioSession *session = [ AVAudioSession sharedInstance ];
    NSString* seccReason = @"";
    NSInteger  reason = [[[notification userInfo] objectForKey:AVAudioSessionRouteChangeReasonKey] integerValue];
//      AVAudioSessionRouteDescription* prevRoute = [[notification userInfo] objectForKey:AVAudioSessionRouteChangePreviousRouteKey];
    switch (reason) {
        case AVAudioSessionRouteChangeReasonNoSuitableRouteForCategory:
            seccReason = @"The route changed because no suitable route is now available for the specified category.";
            break;
        case AVAudioSessionRouteChangeReasonWakeFromSleep:
            seccReason = @"The route changed when the device woke up from sleep.";
            break;
        case AVAudioSessionRouteChangeReasonOverride:
            seccReason = @"The output route was overridden by the app.";
            break;
        case AVAudioSessionRouteChangeReasonCategoryChange:
            seccReason = @"The category of the session object changed.";
            break;
        case AVAudioSessionRouteChangeReasonOldDeviceUnavailable:
            seccReason = @"The previous audio output path is no longer available.";
            break;
        case AVAudioSessionRouteChangeReasonNewDeviceAvailable:
            // changing audio output type will pause the player.
            [[ASAudioPlayerController sharedInstance] pause];
            break;
        case AVAudioSessionRouteChangeReasonUnknown:
        default:
            seccReason = @"The reason for the change is unknown.";
            break;
    }
    AVAudioSessionPortDescription *input = [[session.currentRoute.inputs count]?session.currentRoute.inputs:nil objectAtIndex:0];
    if (input.portType == AVAudioSessionPortHeadsetMic) {
        
    }
}

- (void)dealloc {
    [[MPMusicPlayerController systemMusicPlayer] endGeneratingPlaybackNotifications];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                  name:MPMusicPlayerControllerVolumeDidChangeNotification
                                object:[MPMusicPlayerController systemMusicPlayer]];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionRouteChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:nil];
}

- (void)handleInterruption:(NSNotification *)notification {

    NSNumber *interruptionType = [notification.userInfo objectForKey:AVAudioSessionInterruptionTypeKey];
    if (interruptionType.integerValue == AVAudioSessionInterruptionTypeBegan) {
        if (self.playbackState == MPMusicPlaybackStatePlaying) {
            self.interrupted = YES;
        }
        [self pause];
    } else if(interruptionType.integerValue == AVAudioSessionInterruptionTypeEnded) {
        NSNumber* interruptionOption = [[notification userInfo] objectForKey:AVAudioSessionInterruptionOptionKey] ;
        switch (interruptionOption.integerValue) {
            case AVAudioSessionInterruptionOptionShouldResume:
                [self play];
                break;
            default:
                break;
        }
        self.interrupted = NO;
    }
}

- (void)addDelegate:(id<ASAudioPlayerControllerDelegate>)delegate {
    NSMutableArray *delegates = [self.delegates mutableCopy];
    [delegates addObject:delegate];
    self.delegates = delegates;

    // Call the delegate's xChanged methods, so it can initialize its UI

    if ([delegate respondsToSelector:@selector(musicPlayer:playbackStateChanged:previousPlaybackState:)]) {
        [delegate musicPlayer:self playbackStateChanged:self.playbackState previousPlaybackState:MPMusicPlaybackStateStopped];
    }

    if ([delegate respondsToSelector:@selector(musicPlayer:volumeChanged:)]) {
        [delegate musicPlayer:self volumeChanged:self.volume];
    }
}

- (void)removeDelegate:(id<ASAudioPlayerControllerDelegate>)delegate {
    NSMutableArray *delegates = [self.delegates mutableCopy];
    [delegates removeObject:delegate];
    self.delegates = delegates;
}

- (void)setClip:(ASClip *)clip {
    [self stop];
    [self setCurrentPlaybackTime:clip.startTime];
}

- (void)playClip:(ASClip *)clip {
    [self setClip:clip];
    [self play];
}

- (void)playFrom:(NSTimeInterval)startTime {
    [self stop];
    [self setCurrentPlaybackTime:startTime];
    [self play];
    self.playbackState = MPMusicPlaybackStatePlaying;
}

- (void)skip:(BOOL)forward {
    static const float skipInterval = 1.0;
    if (self.playbackState == MPMusicPlaybackStatePlaying) {
        if (forward) {
            [self.player seekToTime:CMTimeMake(self.currentPlaybackTime + skipInterval, 1)];
        } else {
            [self.player seekToTime:CMTimeMake(self.currentPlaybackTime - skipInterval, 1)];
        }
    }
}

#pragma mark - MPMediaPlayback

- (void)play {
    [self.player play];
    self.playbackState = MPMusicPlaybackStatePlaying;
}

- (void)pause {
    [self.player pause];
    self.playbackState = MPMusicPlaybackStatePaused;
}

- (void)stop {
    [self.player pause];
    self.playbackState = MPMusicPlaybackStateStopped;
}

- (void)prepareToPlay {
    NSLog(@"Not supported");
}

- (void)beginSeekingBackward {
    NSLog(@"Not supported");
}

- (void)beginSeekingForward {
    NSLog(@"Not supported");
}

- (void)endSeeking {
    NSLog(@"Not supported");
}

- (BOOL)isPreparedToPlay {
    return YES;
}

- (NSTimeInterval)currentPlaybackTime {
    if (self.player && (self.player.currentTime.timescale != 0)) {
        return (double)self.player.currentTime.value / self.player.currentTime.timescale;
    } else {
        return 0;
    }
}

- (void)setCurrentPlaybackTime:(NSTimeInterval)currentPlaybackTime {
    CMTime t = CMTimeMake(currentPlaybackTime, 1);
    [self.player seekToTime:t];
}

- (float)currentPlaybackRate {
    return self.player.rate;
}

- (void)setCurrentPlaybackRate:(float)currentPlaybackRate {
    self.player.rate = currentPlaybackRate;
}

#pragma mark - Setters and getters

- (void)setOriginalQueue:(NSArray *)originalQueue {
    // The original queue never changes, while queue is shuffled
    _originalQueue = originalQueue;
    self.queue = originalQueue;
}

- (void)setMediaItem:(MPMediaItem *)mediaItem {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

    mediaItem = mediaItem;

    // Used to prevent duplicate notifications
    self.isLoadingAsset = YES;

    // Create a new player item
    NSURL *assetUrl = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
    AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:assetUrl];

    // Either create a player or replace it
    if (self.player) {
        [self.player replaceCurrentItemWithPlayerItem:playerItem];
    } else {
        self.player = [AVPlayer playerWithPlayerItem:playerItem];
    }

    // Subscribe to the AVPlayerItem's DidPlayToEndTime notification.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAVPlayerItemDidPlayToEndTimeNotification) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];

    // Inform iOS now playing center
    [self doUpdateNowPlayingCenter];

    self.isLoadingAsset = NO;
}

- (void)handleAVPlayerItemDidPlayToEndTimeNotification {
    if (!self.isLoadingAsset) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.playbackState = MPMusicPlaybackStateStopped;
        });
    }
}

- (void)doUpdateNowPlayingCenter {
    if (!self.updateNowPlayingCenter || !self.nowPlayingItem) {
        return;
    }

    MPNowPlayingInfoCenter *center = [MPNowPlayingInfoCenter defaultCenter];
    NSMutableDictionary *songInfo = [NSMutableDictionary dictionaryWithDictionary:@{
        MPMediaItemPropertyArtist: [self.nowPlayingItem valueForProperty:MPMediaItemPropertyArtist] ?: @"",
        MPMediaItemPropertyTitle: [self.nowPlayingItem valueForProperty:MPMediaItemPropertyTitle] ?: @"",
        MPMediaItemPropertyAlbumTitle: [self.nowPlayingItem valueForProperty:MPMediaItemPropertyAlbumTitle] ?: @"",
        MPMediaItemPropertyPlaybackDuration: [self.nowPlayingItem valueForProperty:MPMediaItemPropertyPlaybackDuration] ?: @0
    }];

    // Add the artwork if it exists
    MPMediaItemArtwork *artwork = [self.nowPlayingItem valueForProperty:MPMediaItemPropertyArtwork];
    if (artwork) {
        songInfo[MPMediaItemPropertyArtwork] = artwork;
    }

    center.nowPlayingInfo = songInfo;
}

- (void)setPlaybackState:(MPMusicPlaybackState)playbackState {
    if (playbackState == _playbackState) {
        return;
    }

    MPMusicPlaybackState oldState = _playbackState;
    _playbackState = playbackState;

    for (id <ASAudioPlayerControllerDelegate> delegate in self.delegates) {
        if ([delegate respondsToSelector:@selector(musicPlayer:playbackStateChanged:previousPlaybackState:)]) {
            [delegate musicPlayer:self playbackStateChanged:_playbackState previousPlaybackState:oldState];
        }
    }
}

#pragma mark - Other public methods

- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent {
    if (receivedEvent.type != UIEventTypeRemoteControl) {
        return;
    }

    switch (receivedEvent.subtype) {
        case UIEventSubtypeRemoteControlTogglePlayPause: {
            if (self.playbackState == MPMusicPlaybackStatePlaying) {
                [self pause];
            } else {
                [self play];
            }
            break;
        }

        case UIEventSubtypeRemoteControlPlay:
            [self play];
            break;

        case UIEventSubtypeRemoteControlPause:
            [self pause];
            break;

        case UIEventSubtypeRemoteControlStop:
            [self stop];
            break;

        case UIEventSubtypeRemoteControlBeginSeekingBackward:
            [self beginSeekingBackward];
            break;

        case UIEventSubtypeRemoteControlBeginSeekingForward:
            [self beginSeekingForward];
            break;

        case UIEventSubtypeRemoteControlEndSeekingBackward:
        case UIEventSubtypeRemoteControlEndSeekingForward:
            [self endSeeking];
            break;

        default:
            break;
    }
}

@end
