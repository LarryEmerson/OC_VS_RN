//
//  LEMusicPlayer.h
//  MT_Study
//
//  Created by emerson larry on 2017/7/21.
//  Copyright © 2017年 LarryEmerson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LEUIMaker/LEUIMaker.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
@interface LEMusicPlayer : NSObject
LESingleton_interface(LEMusicPlayer)
@property (nonatomic) BOOL isPlaying;
@property (nonatomic) AVPlayer *playView; 
-(void) play; 
-(void) playWithURL:(NSURL *) url;
-(void) pause;
-(void) stop;
-(void) playOrPause;
@end
