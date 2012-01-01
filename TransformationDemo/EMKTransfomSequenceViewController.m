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
#import "EMKScrubber.h"


@interface EMKTransfomSequenceViewController () <EMKTransformationEditorDelegate>

@property(readwrite, nonatomic, strong) EMKTransformationEditor *transformEditor;
@property(readwrite, nonatomic, strong) NSMutableArray  *transforms;
@property(readwrite, nonatomic) NSUInteger currentTransformIndex;
@property(readwrite, nonatomic) CATransform3D currentTransform;


-(void)adjustEditorPaletteToCurrentOrientation;
@end


@implementation EMKTransfomSequenceViewController


#pragma mark - properties
@synthesize actor = _actor;
@synthesize stage = _stage;
@synthesize centerStage = _centerStage;
@synthesize spotLight = _spotLight;

@synthesize transforms = _transforms;
@synthesize currentTransformIndex = _currentTransformIndex;

@synthesize editorPalette = _editorPalette;
@synthesize transformEditor = _transformEditor;
@synthesize transformationScrubber = _transformationScrubber;



-(CATransform3D)currentTransform
{    
    return [[self.transforms objectAtIndex:self.currentTransformIndex] CATransform3DValue];
}



-(void)setCurrentTransform:(CATransform3D)aTransform
{
    [self.transforms replaceObjectAtIndex:self.currentTransformIndex withObject:[NSValue valueWithCATransform3D:aTransform]];
}



#pragma mark - instance life cycle
//set up base transformation
-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        _transforms = [NSMutableArray arrayWithObjects:[NSValue valueWithCATransform3D:CATransform3DIdentity], [NSValue valueWithCATransform3D:CATransform3DIdentity], nil];
    }
    return self;
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
    
    
    //configure editorPalette and create array for storing editors
    UIScrollView *editorPalette = self.editorPalette;
    editorPalette.pagingEnabled = YES;
    editorPalette.showsHorizontalScrollIndicator = NO;        

    //create array to store the editor views    
    NSMutableArray *editorViews = [NSMutableArray new];
        
    //create transformEditor and add view to editor views
    EMKTransformationEditor *transformEditor = [EMKTransformationEditor new];
    transformEditor.delegate = self;    
    [editorViews addObject:transformEditor.view];
    self.transformEditor = transformEditor;
    
    //position and size the editors and palette
    CGSize paletteSize = editorPalette.frame.size;
    int i = 0;
    for (UIView *view in editorViews)
    {
        view.frame = (CGRect){.size = paletteSize, .origin = CGPointMake(i * paletteSize.width, 0)};
        view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [editorPalette addSubview:view];
        i++;
    }
    //size the editorPalette
    editorPalette.contentSize = CGSizeMake(paletteSize.width * [editorViews count], paletteSize.height);    
    
    
    //configure the scrubber
    EMKScrubber *scrubber = self.transformationScrubber;
    scrubber.duration = 2;
    [scrubber reloadData];
    scrubber.selectedMarkIndex = self.currentTransformIndex;
    scrubber.selectedMark.backgroundColor = [UIColor blueColor];        
}



#pragma marks - rotation
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}



-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self adjustEditorPaletteToCurrentOrientation];
}



-(void)adjustEditorPaletteToCurrentOrientation
{
    UIScrollView *paletteScrollView = self.editorPalette;
    
    //TODO: determine index from contentSize and contentOffset
    NSUInteger index = 0;
    NSUInteger editorCount = 1;
    
    
    //adjust contentOffset (only x has changed)
    CGSize postRotationPaletteSize = paletteScrollView.frame.size;    
    paletteScrollView.contentOffset = CGPointMake(postRotationPaletteSize.width * index, 0);    
    
    //adjust contentSize (only width has changed)
    CGSize postRotationContentSize = (CGSize){.width = postRotationPaletteSize.width * editorCount, .height = postRotationPaletteSize.height};    
    paletteScrollView.contentSize = postRotationContentSize;    
}



#pragma mark - view refreshing
-(void)refreshActor
{
    self.actor.layer.transform = self.currentTransform;
}



#pragma mark - scrubber data source
-(NSUInteger)numberOfMarksInScrubber:(EMKScrubber *)scrubber
{
    return 2;// [self.transforms count];
}



-(NSTimeInterval)scrubber:(EMKScrubber *)scrubber timeForMark:(NSUInteger)markIndex
{    
    return scrubber.duration * (CGFloat)markIndex / (2.0 - 1.0);
}
    


#pragma mark - scrubber delegate
-(void)scrubber:(EMKScrubber *)scrubber didSelectMark:(NSUInteger)markIndex
{
    for (UIView* mark in [scrubber marks])
    {
        mark.backgroundColor = [UIColor lightGrayColor];
    }
    
    scrubber.selectedMark.backgroundColor = [UIColor blueColor];    
    
    self.currentTransformIndex = markIndex;
    self.transformEditor.transformation = self.currentTransform;
    [self refreshActor];
}



#pragma mark - transformationEditor delegate
-(void)transformationEditorTransformationChanged:(EMKTransformationEditor *)transformationEditor
{
    self.currentTransform = transformationEditor.transformation;
    [self refreshActor];
}




#pragma mark - actions
-(IBAction)resetTransformation
{
    self.currentTransform = CATransform3DIdentity;
    self.transformEditor.transformation = self.currentTransform;
    [self refreshActor];    
}



-(IBAction)play
{
    //get the relevant editors
    NSArray *transforms = self.transforms;
    CATransform3D start = [[transforms objectAtIndex:0] CATransform3DValue];
    CATransform3D end = [[transforms lastObject] CATransform3DValue];
    
    [CATransaction begin];
    
    //configure the animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
    [animation setFromValue:[NSValue valueWithCATransform3D:start]];
    [animation setToValue:[NSValue valueWithCATransform3D:end]];    
    [animation setDuration:self.transformationScrubber.duration];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];

    //set the transformation model to the current state so that when the animation ends it represents the model
    CALayer *layer = self.actor.layer;
    layer.transform = self.currentTransform;

    //update the editor to reflect the presentation layer
    CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(refreshTransform)];    
    [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    
    //remove the display link on completion
    [CATransaction setCompletionBlock:^{
        [displayLink invalidate];
    }];
    
    
    //add the animation
    [layer addAnimation:animation forKey:@"transformation"];    
     
    [CATransaction commit];
}


-(void)refreshTransform
{
    self.transformEditor.transformation = [(CALayer *)self.actor.layer.presentationLayer transform];
}

@end

