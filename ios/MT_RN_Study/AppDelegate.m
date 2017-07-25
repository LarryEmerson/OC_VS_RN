/**
 * Copyright (c) 2015-present, Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD-style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 */

#import "AppDelegate.h"

#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>
 
@implementation AppDelegate
LESingleton_implementation(AppDelegate)
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  NSURL *jsCodeLocation;

  jsCodeLocation = [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index.ios" fallbackResource:nil];

  RCTRootView *rootView = [[RCTRootView alloc] initWithBundleURL:jsCodeLocation
                                                      moduleName:@"MT_RN_Study"
                                               initialProperties:nil
                                                   launchOptions:launchOptions];
  rootView.backgroundColor = [[UIColor alloc] initWithRed:1.0f green:1.0f blue:1.0f alpha:1];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;
  
  UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:rootViewController];
  [[UINavigationBar appearance] setTintColor:LEColorBlack];
  [[UINavigationBar appearance] setBackgroundImage:[LEColorWhite leImage] forBarPosition:UIBarPositionTop barMetrics:UIBarMetricsDefault];
  [[UINavigationBar appearance] setBarStyle:UIBarStyleDefault];
  [nav setNavigationBarHidden:YES animated:YES];
  
  self.window.rootViewController = nav;
  [self.window makeKeyAndVisible];
  return YES;
}
@end
