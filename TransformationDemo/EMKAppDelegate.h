//
//  EMKAppDelegate.h
//  TransformationDemo
//
//  Created by Benedict Cohen on 24/12/2011.
//  Copyright (c) 2011 Benedict Cohen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EMKTransfomSequenceViewController;

@interface EMKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) EMKTransfomSequenceViewController *viewController;

@end
