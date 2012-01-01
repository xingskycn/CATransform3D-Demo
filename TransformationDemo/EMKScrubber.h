//
//  EMKScrubber.h
//  TransformationDemo
//
//  Created by Benedict Cohen on 28/12/2011.
//  Copyright (c) 2011 Benedict Cohen. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EMKScrubber;
@protocol EMKScrubberDataSource <NSObject>

-(NSUInteger)numberOfMarksInScrubber:(EMKScrubber *)scrubber;
-(NSTimeInterval)scrubber:(EMKScrubber *)scrubber timeForMark:(NSUInteger)markIndex;

@end


@protocol EMKScrubberDelegate <NSObject>
//TODO:
-(void)scrubber:(EMKScrubber *)scrubber configureView:(UIView *)mark forMarkAtIndex:(NSUInteger)markIndex;
-(UIView *)scrubberChangedTime:(EMKScrubber *)scrubber;
-(UIView *)scrubber:(EMKScrubber *)scrubber didSelectMark:(NSUInteger)markIndex;

@end



@interface EMKScrubber : UIView
@property(readwrite, nonatomic) NSTimeInterval duration;
@property(readwrite, nonatomic) NSTimeInterval currentTime;

@property(readonly, nonatomic, weak) IBOutlet id<EMKScrubberDataSource> dataSource;
@property(readonly, nonatomic, weak) IBOutlet id<EMKScrubberDelegate> delegate;
@property(readonly, nonatomic) NSUInteger numberOfMarks;

@property(readwrite, nonatomic) NSUInteger selectedMarkIndex;
@property(readonly, nonatomic) UIView *selectedMark;

@property(readonly, nonatomic, strong) UIView *playerHead;

@property(readonly, nonatomic, strong) NSArray *marks;
-(UIView *)markForIndex:(NSUInteger)markIndex;

-(void)reloadData;

-(void)play;
-(void)pause;
-(void)isPlaying;
@end
