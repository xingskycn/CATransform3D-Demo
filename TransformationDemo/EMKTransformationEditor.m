//
//  EMKTransformationEditor.m
//  TransformationDemo
//
//  Created by Benedict Cohen on 25/12/2011.
//  Copyright (c) 2011 Benedict Cohen. All rights reserved.
//

#import "EMKTransformationEditor.h"
#import "EMKNumberEditor.h"
#import "CATransform3DFieldAccessors.h"


@interface EMKTransformationEditor () <EMKNumberEditorDelegate>
@property(readwrite, nonatomic, strong) NSArray *cells;
@property(readonly, nonatomic, strong) EMKNumberEditor *numberEditor;
@property(readwrite, nonatomic) CATransform3DField selectedField;

-(void)viewDidLoad;
-(void)setValue:(CGFloat)value forTransformationField:(CATransform3DField)field;
-(CGFloat)valueForTransformationField:(CATransform3DField)field;
-(void)refreshView;
-(NSString *)titleForTransformField:(CATransform3DField)field;
@end



@implementation EMKTransformationEditor


#pragma mark - properties
@synthesize selectedField = _selectedField;
@synthesize delegate = _delegate;
@synthesize cells = _cells;
@synthesize transformation = _transformation;
-(void)setTransformation:(CATransform3D)transformation
{
    _transformation = transformation;
    [self refreshView];
}



@synthesize view = _view;
-(UIView *)view
{
    if (_view == nil)
    {        
        _view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
        [self viewDidLoad];
    }
    
    return _view;
}



@synthesize numberEditor = _numberEditor;
-(EMKNumberEditor *)numberEditor
{
    if (_numberEditor == nil) 
    {
        _numberEditor = [[EMKNumberEditor alloc] initWithNibName:nil bundle:nil];
        _numberEditor.delegate = self;

    }
    return _numberEditor;
}



#pragma mark - instance life cycle
-(id)init
{
    self = [super init];
    if (self)
    {
        _transformation = CATransform3DIdentity;
    }
    return self;
}



#pragma mark - view life cycle
-(void)viewDidLoad
{
    const int rowCount = CATransform3DDimensionLength;
    const int colCount = CATransform3DDimensionLength;    

    
    //create a grid to represent the matrix
    NSMutableArray *cells = [NSMutableArray arrayWithCapacity:rowCount * colCount];
    UIView *containingView = self.view;
    CGRect containingFrame = containingView.frame;
    CGSize cellSize = CGSizeMake(containingFrame.size.width/colCount, containingFrame.size.height/rowCount);
    for (int row = 0; row < rowCount; row++)
    {
        for (int col = 0; col < colCount; col++)
        {
            CGRect frame = (CGRect){.size = cellSize, .origin = CGPointMake(col * cellSize.width, row * cellSize.height)};
            UILabel *cell = [[UILabel alloc] initWithFrame:frame];
            cell.backgroundColor = [UIColor greenColor];
            cell.textAlignment = UITextAlignmentCenter;
            cell.tag = CATransform3DFields[(row * colCount) + col]; //set tag to a field
            cell.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            cell.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didRecognizeLabelTap:)];
            [cell addGestureRecognizer:tapRecognizer];
            
            [containingView addSubview:cell];
            [cells addObject:cell];
        }
    }
    
    self.cells = cells;
    
    [self refreshView];
}



#pragma mark - actions
-(void)didRecognizeLabelTap:(UITapGestureRecognizer *)sender
{
    //get the cell and the field
    UIView *cell = sender.view;    
    CATransform3DField field = cell.tag;

    //keep track of the selected field so we can update it in numberEditorValueChanged:
    self.selectedField = field;
    
    //set up numberEditor
    EMKNumberEditor *numberEditor = self.numberEditor;        
    numberEditor.value = [self valueForTransformationField:field];
    numberEditor.title = [self titleForTransformField:field];

    //we want to allow taps on other cells to show the editor for them
    //(the default would be to dismiss the editor)
    NSArray *passthroughViews = [self.cells filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self != %@", cell]];    
    
    //present the editor
    [numberEditor presentInPopoverFromRect:cell.frame inView:cell.superview permittedArrowDirections:UIPopoverArrowDirectionLeft | UIPopoverArrowDirectionRight animated:YES passthroughViews:passthroughViews];
}



#pragma mark - value editor delegate
-(void)numberEditorValueChanged:(EMKNumberEditor *)numberEditor
{
    //update self.transform
    CGFloat value = numberEditor.value;
    CATransform3DField field = self.selectedField;
    
    [self setValue:value forTransformationField:field];
}



#pragma mark - updating transformation
-(void)setValue:(CGFloat)value forTransformationField:(CATransform3DField)field
{
    //update the transformation and tell the delegate
    self.transformation = CATransform3DSetField(self.transformation, field, value);

    [self.delegate transformationEditorTransformationChanged:self];
}



-(CGFloat)valueForTransformationField:(CATransform3DField)field
{
    return CATransform3DFieldValue(self.transformation, field);
}


#pragma mark - view refreshing methods
-(void)refreshView
{
    for (UILabel *cell in self.cells)
    {
        cell.text = [NSString stringWithFormat:@"%0.3f", [self valueForTransformationField:cell.tag]];
    }
}



-(NSString *)titleForTransformField:(CATransform3DField)field
{
    switch (field)
    {
        case CATransform3DFieldM11: return @"m11";
        case CATransform3DFieldM12: return @"m12";
        case CATransform3DFieldM13: return @"m13";
        case CATransform3DFieldM14: return @"m14";            
            
        case CATransform3DFieldM21: return @"m21";
        case CATransform3DFieldM22: return @"m22";
        case CATransform3DFieldM23: return @"m23";
        case CATransform3DFieldM24: return @"m24";            

        case CATransform3DFieldM31: return @"m31";
        case CATransform3DFieldM32: return @"m32";
        case CATransform3DFieldM33: return @"m33";
        case CATransform3DFieldM34: return @"m34";            

        case CATransform3DFieldM41: return @"m41";
        case CATransform3DFieldM42: return @"m42";
        case CATransform3DFieldM43: return @"m43";
        case CATransform3DFieldM44: return @"m44";            
    }
}


@end
