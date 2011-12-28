//
//  EMKAppDelegate.m
//  TransformationDemo
//
//  Created by Benedict Cohen on 24/12/2011.
//  Copyright (c) 2011 Benedict Cohen. All rights reserved.
//

#import "EMKAppDelegate.h"

#import "EMKTransfomSequenceViewController.h"

@implementation EMKAppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.viewController = [[EMKTransfomSequenceViewController alloc] initWithNibName:@"EMKViewController" bundle:nil];
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
