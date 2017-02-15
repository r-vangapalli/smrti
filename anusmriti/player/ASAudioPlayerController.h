#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@class ASAudioPlayerController;
@class ASClip;

@protocol ASAudioPlayerControllerDelegate <NSObject>
@optional
- (void)musicPlayer:(ASAudioPlayerController *)musicPlayer playbackStateChanged:(MPMusicPlaybackState)playbackState previousPlaybackState:(MPMusicPlaybackState)previousPlaybackState;
- (void)musicPlayer:(ASAudioPlayerController *)musicPlayer volumeChanged:(float)volume;
@end


@interface ASAudioPlayerController : NSObject <MPMediaPlayback>

@property (nonatomic) MPMusicPlaybackState playbackState;
@property (nonatomic) float volume;
@property (nonatomic) BOOL updateNowPlayingCenter;
@property (nonatomic, weak) MPMediaItem *mediaItem;

+ (ASAudioPlayerController *)sharedInstance;

- (void)setClip:(ASClip *)clip;
- (void)playClip:(ASClip *)clip;
- (void)playFrom:(NSTimeInterval)startTime;
- (void)skip:(BOOL)forward;

- (void)addDelegate:(id<ASAudioPlayerControllerDelegate>)delegate;
- (void)removeDelegate:(id<ASAudioPlayerControllerDelegate>)delegate;
- (void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent;

@end
