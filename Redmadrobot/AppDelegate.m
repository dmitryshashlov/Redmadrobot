//
//  AppDelegate.m
//  Redmadrobot
//
//  Created by Dmitry Shashlov on 11/18/14.
//  Copyright (c) 2014 Dmitry Shashlov. All rights reserved.
//

#import "AppDelegate.h"
#import <InstagramKit/InstagramKit.h>

#import "RMSearchViewController.h"
#import "RMCollageViewController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation AppDelegate

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{  
  // Window
  self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
  self.window.backgroundColor = [UIColor whiteColor];
  [self.window makeKeyAndVisible];

  // Collage controller
  RMCollage *collage = [[RMCollage alloc] initWithSize:@3];
  RMCollageViewModel *collageViewModel = [[RMCollageViewModel alloc] initWithCollage:collage];
  RMCollageViewController *collageController = [[RMCollageViewController alloc] initWithCollageViewModel:collageViewModel
                                                                                          productionStep:RMCollageProductionStepGrid];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:collageController];
  self.window.rootViewController = navController;
  
  return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationWillResignActive:(UIApplication *)application
{
  //
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationDidEnterBackground:(UIApplication *)application
{
  //
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationWillEnterForeground:(UIApplication *)application
{
  //
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationDidBecomeActive:(UIApplication *)application
{
  //
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
- (void)applicationWillTerminate:(UIApplication *)application
{
  //
}

@end
