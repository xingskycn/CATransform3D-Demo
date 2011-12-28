//
//  EMKNumberEditor.h
//  TransformationDemo
//
//  Created by Benedict Cohen on 25/12/2011.
//  Copyright (c) 2011 Benedict Cohen. All rights reserved.
//

#import <Foundation/Foundation.h>

@class EMKNumberEditor;
@protocol EMKNumberEditorDelegate <NSObject>
-(void)numberEditorValueChanged:(EMKNumberEditor *)numberEditor;

@end


@interface EMKNumberEditor : UIViewController

@property(readwrite, nonatomic) CGFloat value;
@property(readwrite, nonatomic, weak) id<EMKNumberEditorDelegate> delegate;

-(void)presentInPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirection animated:(BOOL)animated passthroughViews:(NSArray *)passthroughViews;
@end


//Interface Builder properties
@interface EMKNumberEditor ()

@property(readwrite, nonatomic, strong) IBOutlet UIPickerView *numberPicker;

@end
