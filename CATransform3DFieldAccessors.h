//
//  CATransform3DFieldAccessors.h
//  TransformationDemo
//
//  Created by Benedict Cohen on 26/12/2011.
//  Copyright (c) 2011 Benedict Cohen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

typedef enum {
    CATransform3DFieldM11,
    CATransform3DFieldM12,
    CATransform3DFieldM13,
    CATransform3DFieldM14,    
    
    CATransform3DFieldM21,
    CATransform3DFieldM22,
    CATransform3DFieldM23,
    CATransform3DFieldM24,    
    
    CATransform3DFieldM31,
    CATransform3DFieldM32,
    CATransform3DFieldM33,
    CATransform3DFieldM34,    
    
    CATransform3DFieldM41,
    CATransform3DFieldM42,
    CATransform3DFieldM43,
    CATransform3DFieldM44
} CATransform3DField;


extern const CATransform3DField CATransform3DFields[]; 
extern const CFIndex CATransform3DDimensionLength;

CATransform3D CATransform3DSetField(CATransform3D transform, CATransform3DField field, CGFloat value);
CGFloat CATransform3DFieldValue(CATransform3D transform, CATransform3DField field);