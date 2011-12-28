//
//  EMKTransformationEditor.h
//  TransformationDemo
//
//  Created by Benedict Cohen on 25/12/2011.
//  Copyright (c) 2011 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <QuartzCore/QuartzCore.h>


@class EMKTransformationEditor;
@protocol EMKTransformationEditorDelegate <NSObject>
-(void)transformationEditorTransformationChanged:(EMKTransformationEditor *)transformationEditor;
@end


@interface EMKTransformationEditor : NSObject

@property(readonly, nonatomic, strong) IBOutlet UIView *view;
@property(readwrite, nonatomic) CATransform3D transformation;
@property(readwrite, nonatomic, weak) id<EMKTransformationEditorDelegate> delegate;

@end

