//
//  EMKTransfomSequenceViewController.h
//  TransformationDemo
//
//  Created by Benedict Cohen on 24/12/2011.
//  Copyright (c) 2011 Benedict Cohen. All rights reserved.
//

#import <UIKit/UIKit.h>
@class EMKScrubber;

@interface EMKTransfomSequenceViewController : UIViewController

@property(readwrite, nonatomic, strong) IBOutlet UIView *stage;
@property(readwrite, nonatomic, strong) IBOutlet UIView *centerStage;
@property(readwrite, nonatomic, strong) UIView *spotLight;
@property(readwrite, nonatomic, strong) IBOutlet UIView *actor;

@property(readwrite, nonatomic, strong) IBOutlet UIScrollView *editorPalette;
@property(readwrite, nonatomic, strong) IBOutlet EMKScrubber *transformationScrubber;

-(IBAction)resetTransformation;
-(IBAction)play;
@end
