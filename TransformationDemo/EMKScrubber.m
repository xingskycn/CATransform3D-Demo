//
//  EMKScrubber.m
//  TransformationDemo
//
//  Created by Benedict Cohen on 28/12/2011.
//  Copyright (c) 2011 Benedict Cohen. All rights reserved.
//

#import "EMKScrubber.h"

@interface EMKScrubber ()
@property(readwrite, nonatomic, strong) NSArray *marks;
-(UIView *)createMarkForIndex:(NSUInteger)markIndex;
-(void)configureView:(UIView *)mark forMarkAtIndex:(NSUInteger)markIndex;
@end




@implementation EMKScrubber

#pragma mark - properties
@synthesize marks = _marks;
@synthesize duration = _duration;
@synthesize currentTime = _currentTime;
@synthesize dataSource = _dataSource;
@synthesize delegate = _delegate;
@synthesize selectedMarkIndex = _selectedMarkIndex;


-(UIView *)selectedMark
{
    return [self.marks objectAtIndex:self.selectedMarkIndex];
}




@synthesize playerHead = _playerHead;
-(UIView *)playerHead
{
    if (_playerHead)
    {
        _playerHead = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 2, 44)];        
    }
    
    return _playerHead;
}



-(NSUInteger)numberOfMarks
{
    id<EMKScrubberDataSource> dataSource = self.dataSource;
    return (dataSource) ? [dataSource numberOfMarksInScrubber:self] : 0;
}



#pragma mark - instance life cycle
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}



#pragma mark - layout
-(void)reloadData
{
    //clear out old marks
    //TODO: Should we also remove the tap recognizer?
    //The view could be being retained/used else where. If the tap recognizer fires it would cause a exception.
    [self.marks makeObjectsPerformSelector:@selector(removeFromSuperview)];    
    
    //create new marks storage
    NSUInteger markCount = self.numberOfMarks;
    NSMutableArray *marks = [NSMutableArray arrayWithCapacity:markCount];    
    self.marks = marks;

    //values required for layouting marks       
    const CGFloat maxWidth = self.bounds.size.width;
    const CGFloat verticalCenter = self.bounds.size.height/2;

    //duration and intervals are used to determine x position the marks
    const NSTimeInterval duration = self.duration;    
    NSTimeInterval *intervals = malloc(sizeof(NSTimeInterval) * markCount);

    //we update leftOverflow and rightOverflow depending on where the marks are positioned
    CGFloat leftOverflow  = 0;
    CGFloat rightOverflow = 0;    
    
    
    //Position marks: pass 1
    //In pass 1 we assume that the frame of each mark stays within self.bounds
    //We check to see if this assumption is correct. If not then we take pass 2
    //NB: We could do this in 1 pass, but that would require positioning the marks out of order
    for (NSInteger i = 0; i < markCount; i++)
    {
        //get the mark
        UIView *mark = [self createMarkForIndex:i];
        [self addSubview:mark];
        [marks addObject:mark];
        
        //get the interval (we keep it as we may need it in the 2nd pass) and check it's valid
        intervals[i] = [self.dataSource scrubber:self timeForMark:i];
        if (intervals[i] < 0 || intervals[i] > duration)
        {
            //tidy up
            free(intervals);
            
            //raise an exception
            NSString *reason = (intervals[i] < 0) ? [NSString stringWithFormat:@"%@: Attempted to position mark with index %i at interval less than 0.", NSStringFromClass([self class]), i]
                                                  : [NSString stringWithFormat:@"%@: Attempted to position mark with index %i at interval greater than duration.", NSStringFromClass([self class]), i];
            [[NSException exceptionWithName:NSRangeException reason:reason userInfo:nil] raise];
            return;
        }
        
        
        //set marks position based on it's center being the point it represents
        mark.center = CGPointMake(maxWidth * (intervals[i]/duration), verticalCenter);

        //see if mark excceds self.bounds more than any sibling marks
        const CGRect markFrame = mark.frame;
        
        //if mark extends past left border update left overflow        
        const CGFloat canditateLeftOverflow = markFrame.origin.x;
        if (canditateLeftOverflow < leftOverflow) leftOverflow = canditateLeftOverflow; //origin will be negative

        //if mark extends past right border update right overflow
        const CGFloat canditateRightOverflow = (markFrame.origin.x + markFrame.size.width) - maxWidth;        
        if (canditateRightOverflow > rightOverflow) rightOverflow = canditateRightOverflow;   
    }
    
    
    //Position marks: pass 2
    //a second pass is only required if we exceeded the available width on the first pass
    BOOL isSecondLayoutPassRequired = leftOverflow < 0 || rightOverflow > 0;
    if (isSecondLayoutPassRequired)
    {     
        //determine how much width we have to use
        const CGFloat leftInset  = abs(leftOverflow);
        const CGFloat rightInset = abs(rightOverflow);
        const CGFloat dataInkWidth = maxWidth - (leftInset + rightInset);

        int i = 0;
        for (UIView *mark in marks)
        {
            //position mark based on the reduced data ink width
            mark.center = CGPointMake(leftInset + ((dataInkWidth * intervals[i])/duration), verticalCenter);        
            i++;
        }
    }
    

    //tidy up
    free(intervals);
}




-(void)layoutSubviews
{
//    [self reloadData];
}



#pragma mark - sub view fetching/creation
-(UIView *)markForIndex:(NSUInteger)markIndex
{
    return [self.marks objectAtIndex:markIndex];
}



-(UIView *)createMarkForIndex:(NSUInteger)markIndex
{
    //create an empty view
    static const CGRect markFrame = (CGRect){.origin = (CGPoint){.x = 0, .y = 0}, .size = (CGSize){.width = 44, .height = 44}};
    UIView *mark = [[UIView alloc] initWithFrame:markFrame];
    mark.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;

    //add a tap recognizer
    mark.userInteractionEnabled = YES;    
    UIGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMark:)];
    [mark addGestureRecognizer:tapRecognizer];
    
    //make it look pretty
    id<EMKScrubberDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(scrubber:configureView:forMarkAtIndex:)])
    {
        [delegate scrubber:self configureView:mark forMarkAtIndex:markIndex];
    }        
    else
    {
        [self configureView:mark forMarkAtIndex:markIndex];
    }
    
    //TODO: should we ensure that frame is correct?
    
    return mark;
}



-(void)configureView:(UIView *)mark forMarkAtIndex:(NSUInteger)markIndex
{
    mark.backgroundColor = [UIColor lightGrayColor];    
}



#pragma mark - actions
-(void)didTapMark:(UITapGestureRecognizer *)tapRecognizer
{
    NSUInteger markIndex = [self.marks indexOfObject:tapRecognizer.view];
    
    if (markIndex == NSNotFound)
    {        
        NSString *reason = [NSString stringWithFormat:@"%@ - did receive tap from unknown mark!", NSStringFromClass([self class])];
        [[NSException exceptionWithName:NSInternalInconsistencyException reason:reason userInfo:nil] raise];
        return;
    }
    
    //update state
    self.selectedMarkIndex = markIndex;
    
    
    id<EMKScrubberDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(scrubber:didSelectMark:)])
    {
        [delegate scrubber:self didSelectMark:markIndex];
    }
}




-(void)play
{
    
}



-(void)pause
{
    
}



-(void)isPlaying
{
    

}


@end
