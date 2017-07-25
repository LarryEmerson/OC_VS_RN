//
//  LEMusicPlayer.m
//  MT_Study
//
//  Created by emerson larry on 2017/7/21.
//  Copyright © 2017年 LarryEmerson. All rights reserved.
//

#import "LEMusicPlayer.h"
#import <notify.h>
@interface LEMusicPlayer ()
@property (nonatomic) UIBackgroundTaskIdentifier bgTaskId;
@property (nonatomic) id playerTimeObserver;
@end
@implementation LEMusicPlayer{
    MPRemoteCommandCenter *rcc;
}
LESingleton_implementation(LEMusicPlayer)

-(void) leAdditionalInits{
    LEWeakSelf(self)
    rcc = [MPRemoteCommandCenter sharedCommandCenter];
    self.playView=[[AVPlayer alloc] initWithPlayerItem:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleInterreption:) name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    //播放结束 通知
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playView.currentItem]; 
    [rcc.pauseCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        LELogObject(@"leAdditionalInits pauseCommand")
        [weakself playOrPause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [rcc.playCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        LELogObject(@"leAdditionalInits playCommand")
        [weakself playOrPause];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
    [rcc.changePlaybackPositionCommand addTargetWithHandler:^MPRemoteCommandHandlerStatus(MPRemoteCommandEvent * _Nonnull event) {
        LELogObject(@"leAdditionalInits changePlaybackPositionCommand")
        CMTime totlaTime = weakself.playView.currentItem.duration;
        MPChangePlaybackPositionCommandEvent * playbackPositionEvent = (MPChangePlaybackPositionCommandEvent *)event;
        [weakself.playView seekToTime:CMTimeMake(totlaTime.value*playbackPositionEvent.positionTime/CMTimeGetSeconds(totlaTime), totlaTime.timescale) completionHandler:^(BOOL finished) {
        }];
        return MPRemoteCommandHandlerStatusSuccess;
    }];
 
    MPSkipIntervalCommand *skipBackwardIntervalCommand = [rcc skipBackwardCommand];
    [skipBackwardIntervalCommand setEnabled:NO];
    MPSkipIntervalCommand *skipForwardIntervalCommand = [rcc skipForwardCommand];
    [skipForwardIntervalCommand setEnabled:NO];
    //开启后台处理多媒体事件
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    AVAudioSession *session=[AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    //设置后台任务ID
    UIBackgroundTaskIdentifier newTaskId=UIBackgroundTaskInvalid;
    newTaskId=[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        LELogObject(@"leAdditionalInits newTaskId")
    }];
    self.playerTimeObserver = [self.playView addPeriodicTimeObserverForInterval:CMTimeMake(0.1*30, 30) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        
        CGFloat currentTime = CMTimeGetSeconds(time);
        CMTime total = weakself.playView.currentItem.duration;
        CGFloat totalTime = CMTimeGetSeconds(total);
        //监听锁屏状态 lock=1则为锁屏状态
        uint64_t locked;
        __block int token = 0;
        notify_register_dispatch("com.apple.springboard.lockstate",&token,dispatch_get_main_queue(),^(int t){
        });
        notify_get_state(token, &locked);
        
        //监听屏幕点亮状态 screenLight = 1则为变暗关闭状态
        uint64_t screenLight;
        __block int lightToken = 0;
        notify_register_dispatch("com.apple.springboard.hasBlankedScreen",&lightToken,dispatch_get_main_queue(),^(int t){
        });
        notify_get_state(lightToken, &screenLight);
        
        BOOL isShowLyricsPoster = NO;
        // NSLog(@"screenLight=%llu locked=%llu",screenLight,locked);
        if (screenLight == 0 && locked == 1) {
            //点亮且锁屏时
            isShowLyricsPoster = YES;
        }else if(screenLight){
            return;
        }
        //展示锁屏歌曲信息，上面监听屏幕锁屏和点亮状态的目的是为了提高效率
        NSMutableDictionary * songDict = [[NSMutableDictionary alloc] init];
        [songDict setObject:[NSNumber numberWithDouble:totalTime]  forKey:MPMediaItemPropertyPlaybackDuration];
        [songDict setObject:[NSNumber numberWithDouble:currentTime] forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
        [songDict setObject:@"Title" forKey:MPMediaItemPropertyTitle];
        [songDict setObject:@"Artist" forKey:MPMediaItemPropertyArtist];
        [songDict setObject:@"AlbumTitle" forKey:MPMediaItemPropertyAlbumTitle];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:songDict];
        //LELog(@"leAdditionalInits %@/%@: %f",[NSNumber numberWithDouble:currentTime],[NSNumber numberWithDouble:totalTime],currentTime/totalTime)
    }];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}
-(void)remoteControlReceivedWithEvent:(UIEvent *)event{
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
            LELogObject(@"play");
            [[LEMusicPlayer sharedInstance] playOrPause];
            break;
        case UIEventSubtypeRemoteControlPause:
            LELogObject(@"pause");
            [[LEMusicPlayer sharedInstance] pause];
            break;
        case UIEventSubtypeRemoteControlNextTrack:
            LELogObject(@"next");
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:
            LELogObject(@"previous");;
            break;
        default:
            break;
    }
}
    
- (void)moviePlayDidEnd:(NSNotification *)notification {
    //LEWeakSelf(self)
    [self.playView.currentItem seekToTime:kCMTimeZero completionHandler:^(BOOL finished){
        LELogObject(@"moviePlayDidEnd");
    }];
}
-(AVPlayer *) playView{
    if(_playView==nil){
        _playView=[[AVPlayer alloc] initWithPlayerItem:nil];
    }
    return _playView;
}

-(void) dealloc{
    [self.playView removeTimeObserver:self.playerTimeObserver];
    self.playerTimeObserver = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVAudioSessionInterruptionNotification object:[AVAudioSession sharedInstance]];
    MPRemoteCommandCenter *commandCenter = [MPRemoteCommandCenter sharedCommandCenter];
    [commandCenter.changePlaybackPositionCommand removeTarget:self];
    [[UIApplication sharedApplication] endBackgroundTask:self.bgTaskId];
}

-(void)handleInterreption:(NSNotification *)sender{
    LELog(@"handleInterreption %@",self.isPlaying?@"Playing":@"Paused");
    if(self.isPlaying){
        [self pause];
    }else{
        [self play];
    }
}
-(void) play{
    [self.playView play];
    self.isPlaying=YES;
    [rcc playCommand];
}
-(void) playWithURL:(NSURL *) url{
    [self.playView replaceCurrentItemWithPlayerItem:[[AVPlayerItem alloc] initWithURL:url]];
    [self.playView play];
    self.isPlaying=YES;
    [rcc playCommand]; 
}
-(void) pause{
    [self.playView pause];
    self.isPlaying=NO;
    [rcc pauseCommand];
}
-(void) stop{
    self.isPlaying=NO;
    [rcc pauseCommand];
    [self.playView pause];
    [self.playView.currentItem cancelPendingSeeks];
    [self.playView.currentItem.asset cancelLoading];
}
-(void) playOrPause{
    if(self.isPlaying){
        [self pause];
    }else{
        [self play];
    }
}
@end
