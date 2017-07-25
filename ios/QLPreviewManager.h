//
//  QLPreviewManager.h
//  MT_RN_Study
//
//  Created by emerson larry on 2017/7/25.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LEUIMaker/LEUIMaker.h>
#import <QuickLook/QuickLook.h>

@interface QLPreviewManager : NSObject
LESingleton_interface(QLPreviewManager)
-(void)openDoc:(NSString *) bundleName;
@end
