//
//  OCvsRN.m
//  OC_VS_RN
//
//  Created by emerson larry on 2017/7/24.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "OCvsRN.h"
#import <UICKeyChainStore/UICKeyChainStore.h>
#import "LEMusicPlayer.h"
#import <React/RCTEventDispatcher.h>
@interface OCvsRN () @end

@implementation OCvsRN
@synthesize bridge = _bridge;
RCT_EXPORT_MODULE();

-(NSArray<NSString *> *)supportedEvents {
  return @[
            @"fetchUUID",
//            @"ocFuncFetchDocList",
//            @"ocFuncPlayMusic",
//            @"ocFuncPlayOrPause",
//            @"ocFuncOpenDoc",
            @"musicStatusSendToRN",
            @"docListSendToRN",
           ];
}

RCT_EXPORT_METHOD(fetchUUID) {
  UICKeyChainStore *keychain = [UICKeyChainStore keyChainStoreWithService:[[NSBundle mainBundle] bundleIdentifier]];
  NSError *error;
  NSString *token = [keychain stringForKey:[[NSBundle mainBundle] bundleIdentifier] error:&error];
  if (error||!token) {
    NSLog(@"%@", error.localizedDescription);
    NSString *deviceUUID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    NSLog(@"%@",deviceUUID);
    [keychain setString:deviceUUID forKey:[[NSBundle mainBundle] bundleIdentifier]];
  }
  token = [keychain stringForKey:[[NSBundle mainBundle] bundleIdentifier] error:&error];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self sendEventWithName:@"fetchUUID" body:token];
  });
}
RCT_EXPORT_METHOD(ocFuncFetchDocList) {
  NSMutableArray *dataSource=[NSMutableArray new];
  [dataSource addObject:@"pdf.pdf"];
  [dataSource addObject:@"doc.doc"];
  [dataSource addObject:@"ppt.ppt"];
  [dataSource addObject:@"pptx.pptx"];
  dispatch_async(dispatch_get_main_queue(), ^{
    [self sendEventWithName:@"docListSendToRN" body:dataSource];
  });
}
RCT_EXPORT_METHOD(ocFuncPlayMusic) {
  dispatch_async(dispatch_get_main_queue(), ^{
    [[LEMusicPlayer sharedInstance] playWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"mp3.mp3" ofType:nil]]];
    [self sendEventWithName:@"musicStatusSendToRN" body:[LEMusicPlayer sharedInstance].isPlaying?@"1":@"0"];
  });
}
RCT_EXPORT_METHOD(ocFuncPlayOrPause) {
  if([LEMusicPlayer sharedInstance].isPlaying){
    [[LEMusicPlayer sharedInstance] pause];
  }else{
    [[LEMusicPlayer sharedInstance] play];
  }
  dispatch_async(dispatch_get_main_queue(), ^{
    [self sendEventWithName:@"musicStatusSendToRN" body:[LEMusicPlayer sharedInstance].isPlaying?@"1":@"0"];
  });
}
RCT_EXPORT_METHOD(ocFuncOpenDoc:(NSString *) doc) {
  LELogObject(doc)
  dispatch_async(dispatch_get_main_queue(), ^{
    [[QLPreviewManager sharedInstance] openDoc:doc];
  });
}


@end
