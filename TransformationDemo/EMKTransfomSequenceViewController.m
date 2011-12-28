//
//  EMKTransfomSequenceViewController.m
//  TransformationDemo
//
//  Created by Benedict Cohen on 24/12/2011.
//  Copyright (c) 2011 Benedict Cohen. All rights reserved.
//

#import "EMKTransfomSequenceViewController.h"
#import "EMKTransformationEditor.h"

#import "EMKTransformationEditor.h"

@interface EMKTransfomSequenceViewController () <EMKTransformationEditorDelegate>

@property(readwrite, nonatomic, strong) NSArray  *transformEditors;
@property(readwrite, nonatomic) NSUInteger currentEditorIndex;
@property(readonly, nonatomic) EMKTransformationEditor *currentEditor;


-(void)adjustTransformationEditorPaletteToCurrentOrientation;
@end


@implementation EMKTransfomSequenceViewController


#pragma mark - properties
@synthesize actor = _actor;
@synthesize stage = _stage;
@synthesize centerStage = _centerStage;
@synthesize spotLight = _spotLight;

@synthesize transformEditors = _transformEditors;
@synthesize transformationEditorPalette = _transformationEditorPalette;
@synthesize transformationPalettePageIndicator = _transformationPalettePageIndicator;

@synthesize currentEditorIndex = _currentEditorIndex;


-(EMKTransformationEditor *)currentEditor
{    
    return [self.transformEditors objectAtIndex:self.currentEditorIndex];
                        
}



#pragma mark - view loading
-(void)viewDidLoad
{
    //The hierachy is as follows (§ denotes views which are NOT in the nib):
    // |-- stage An autosizing view to fill the top of the screen.
    //   |-- centerStage. A transparent view autosized to stay centered on the floor.
    //     |-- § spotLight. A 1 px border to illustrate the bounds of the unaltered actor
    //     |-- actor. The view whos layer we transform
    
    //insert spotLight in front of actor
    UIView *actor = self.actor;
    UIView *spotLight = [[UIView alloc] initWithFrame:actor.frame];
    spotLight.layer.borderColor = [UIColor redColor].CGColor;
    spotLight.layer.borderWidth = 1;
    [actor.superview insertSubview:spotLight aboveSubview:actor];
    self.spotLight = spotLight;
    
    
    //create and store 2 transformEditors
    NSArray *transformEditors = [NSArray arrayWithObjects:[EMKTransformationEditor new], [EMKTransformationEditor new], nil];        
    NSInteger transformEditorsCount = [transformEditors count];    

    self.transformEditors = transformEditors;    
    
    //configure the page indicator
    self.transformationPalettePageIndicator.numberOfPages = transformEditorsCount;
    
    //configure transformationEditorPalette
    UIScrollView *transformationEditorPalette = self.transformationEditorPalette;
    transformationEditorPalette.pagingEnabled = YES;
    transformationEditorPalette.showsHorizontalScrollIndicator = NO;    
    
    //add each editor to the palette
    NSInteger i = 0;
    CGSize paletteSize = transformationEditorPalette.frame.size;
    for (EMKTransformationEditor *transformEditor in transformEditors)
    {
        transformEditor.delegate = self;
        transformEditor.view.frame = (CGRect){.size = paletteSize, .origin = CGPointMake(paletteSize.width * i, 0)};
        transformEditor.view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [transformationEditorPalette addSubview:transformEditor.view];
        
        i++;
    }
    
    transformationEditorPalette.contentSize = CGSizeMake(paletteSize.width * transformEditorsCount, paletteSize.height);    
}



#pragma marks - View management
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}



-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self adjustTransformationEditorPaletteToCurrentOrientation];
}



-(void)adjustTransformationEditorPaletteToCurrentOrientation
{
    UIScrollView *paletteScrollView = self.transformationEditorPalette;
    NSInteger editorCount = [self.transformEditors count];    
    const NSInteger index = self.currentEditorIndex;
    
    //adjust contentOffset (only x has changed)
    CGSize postRotationPaletteSize = paletteScrollView.frame.size;    
    paletteScrollView.contentOffset = CGPointMake(postRotationPaletteSize.width * index, 0);    
    
    //adjust contentSize (only width has changed)
    CGSize postRotationContentSize = (CGSize){.width = postRotationPaletteSize.width * editorCount, .height = postRotationPaletteSize.height};    
    paletteScrollView.contentSize = postRotationContentSize;    
}



#pragma mark - scrollView delegate methods
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    //figure out the new index
    NSInteger newIndex = scrollView.contentOffset.x / scrollView.frame.size.width;
    self.currentEditorIndex = newIndex;
    
    //update page indicator
    UIPageControl *transformationPalettePageIndicator = self.self.transformationPalettePageIndicator;    
    transformationPalettePageIndicator.currentPage = newIndex;

    //update transform
    CATransform3D transform = self.currentEditor.transformation;
    self.actor.layer.transform = transform;
}



#pragma mark - transformationEditor delegate
-(void)transformationEditorTransformationChanged:(EMKTransformationEditor *)transformationEditor
{
    //update the visible animation
    self.actor.layer.transform = self.currentEditor.transformation;
}



#pragma mark - actions
-(IBAction)resetTransformation
{
    EMKTransformationEditor *editor = self.currentEditor;
    editor.transformation = CATransform3DIdentity;
    self.actor.layer.transform = editor.transformation;
}



-(IBAction)play
{
    //get the relevant editors
    NSArray *editors = self.transformEditors;
    EMKTransformationEditor *startEditor = [editors objectAtIndex:0];
    EMKTransformationEditor *endEditor = [editors lastObject];    
    
    //configure the animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    [animation setFromValue:[NSValue valueWithCATransform3D:startEditor.transformation]];
    [animation setToValue:[NSValue valueWithCATransform3D:endEditor.transformation]];    
    [animation setDuration:2];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

    //set the transformation to the current state so
    //that when the animation ends its in the correct state
    CALayer *layer = self.actor.layer;
    layer.transform = self.currentEditor.transformation;
    [layer addAnimation:animation forKey:@"transformation"];
}


@end

