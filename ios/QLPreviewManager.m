//
//  QLPreviewManager.m
//  MT_RN_Study
//
//  Created by emerson larry on 2017/7/25.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "QLPreviewManager.h"
@interface QLPreviewManager ()<QLPreviewControllerDelegate,QLPreviewControllerDataSource>
@property (nonatomic) NSString *qlFileName;
@property (nonatomic) QLPreviewController *preview;
@end
@implementation QLPreviewManager{
}
LESingleton_implementation(QLPreviewManager)

-(void) leAdditionalInits{
  self.preview=[QLPreviewController new];
  self.preview.view.frame=LESCREEN_BOUNDS;
  self.preview.delegate=self;
  self.preview.dataSource=self;
}

-(void)openDoc:(NSString *) bundleName{
  self.qlFileName=bundleName;
  [[[LEUICommon sharedInstance] leGetTopVC] presentViewController:self.preview animated:YES completion:^{
    [self.preview reloadData];
  }];
  [self.preview reloadData];
}
#pragma mark ==== 返回文件的个数
- (NSInteger)numberOfPreviewItemsInPreviewController:(QLPreviewController *)controller {
  return 1;
}
#pragma mark ===== 在此代理处加载需要显示的文件
- (NSURL *)previewController:(QLPreviewController *)previewController previewItemAtIndex:(NSInteger)idx {
  NSString *path=[[NSBundle mainBundle] pathForResource:self.qlFileName ofType:nil];
  NSURL *url=nil;
  if(path){
    url=[NSURL fileURLWithPath:path];
  }
  return url;
}
@end
