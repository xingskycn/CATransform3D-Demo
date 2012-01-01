//
//  EMKNumberEditor.m
//  TransformationDemo
//
//  Created by Benedict Cohen on 25/12/2011.
//  Copyright (c) 2011 Benedict Cohen. All rights reserved.
//

#import "EMKNumberEditor.h"

typedef enum {
    EMKNumberEditorSignSection = 0,
    EMKNumberEditorHundredsSection,
    EMKNumberEditorTensSection,    
    EMKNumberEditorOnesSection,    
    EMKNumberEditorPointSection,
    EMKNumberEditorTenthsSection,    
    EMKNumberEditorHundredthsSection,        
    EMKNumberEditorThousandantsSection,        
    EMKNumberEditorSectionCount,
} EMKNumberEditorPickerSections;


@interface EMKNumberEditor () <UIPopoverControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate>
@property(readwrite, nonatomic, strong) UIPopoverController *activePopoverController;
-(void)refreshNumberPicker;
@end

@implementation EMKNumberEditor

@synthesize value = _value;
-(void)setValue:(CGFloat)value
{
    if (value > 999.999) 
    {
        _value = 999.999;
    }
    else if (value < -999.999)
    {
        _value = -999.999;
    }
    else
    {
        _value = value;
    }
    
    [self refreshNumberPicker];
}



@synthesize delegate = _delegate;
@synthesize numberPicker = _numberPicker;
@synthesize activePopoverController = _activePopoverController;



#pragma mark - view life cycle
-(void)viewDidLoad
{
    [super viewDidLoad];

    [self refreshNumberPicker];
}



#pragma mark - picker data source
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    //±, 10^2, 10^1, 10^0, decimal place, 10^-1, 10^-2, 10^-3
    return EMKNumberEditorSectionCount;
}



- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component)
    {
        case EMKNumberEditorSignSection:  return 2;
        case EMKNumberEditorPointSection: return 1;            
        default: return 10;
    }
}



#pragma mark - picker delegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component)
    {
        case EMKNumberEditorSignSection : return (row == 0) ? @"+" : @"-";
        case EMKNumberEditorPointSection: return @".";            
        default                         : return [NSString stringWithFormat:@"%i", row % 10];
    }
}



-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //Construct a string that reperesents the value
    NSMutableString *valueString = [NSMutableString string];
    NSInteger colCount = pickerView.numberOfComponents;
    for (int i = 0; i < colCount; i++)
    {
        NSInteger selectedRow = [pickerView selectedRowInComponent:i];
        [valueString appendString: [pickerView.delegate pickerView:pickerView titleForRow:selectedRow forComponent:i]];
    }
    
    //extract the float value and set self.value
    CGFloat value = [valueString floatValue];
    self.value = value;
    
    [self.delegate numberEditorValueChanged:self];
}



#pragma mark - presenting as a popover
-(void)presentInPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirection animated:(BOOL)animated passthroughViews:(NSArray *)passthroughViews
{
    [self.activePopoverController dismissPopoverAnimated:YES];
    
    UINavigationController *navController = (self.navigationController == nil) ? [[UINavigationController alloc] initWithRootViewController:self] : self.navigationController;
        
    UIPopoverController *popoverController = [[UIPopoverController alloc] initWithContentViewController:navController];
    popoverController.delegate = self;
    CGSize contentSize = self.view.frame.size;
    //TODO: figure out where that 8 is coming from!
    CGFloat magicHeight = navController.navigationBar.frame.size.height - 8;
    popoverController.popoverContentSize = CGSizeMake(contentSize.width, contentSize.height + magicHeight);
    popoverController.passthroughViews = passthroughViews;
    
    self.activePopoverController = popoverController;

    
    [popoverController presentPopoverFromRect:rect inView:view permittedArrowDirections:arrowDirection animated:animated];
}





-(void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.activePopoverController = nil;
}



#pragma mark - refresh view
-(void)refreshNumberPicker
{
    //Update pickerview state
    NSString *stringValue = [NSString stringWithFormat:@"%+08.3f", self.value];
    
    UIPickerView *numberPicker = self.numberPicker;
    NSInteger count = [stringValue length];
    for (int i = 0; i < count; i++)
    {
        NSString *character = [stringValue substringWithRange:NSMakeRange(i, 1)];
        switch (i)
        {
            case EMKNumberEditorSignSection:
                if ([character isEqualToString:@"-"])
                {
                    [numberPicker selectRow:1 inComponent:i animated:NO];
                }
                else
                {
                    [numberPicker selectRow:0 inComponent:i animated:NO];
                }
                break;
                
                
            case EMKNumberEditorPointSection:
                //do nothing as "." is the only possible value
                break;
                
                
            default:
                [numberPicker selectRow:[character integerValue] inComponent:i animated:NO];
                break;
        }
    }    
}

@end
