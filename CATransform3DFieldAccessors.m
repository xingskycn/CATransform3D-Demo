//
//  CATransform3DFieldAccessors.m
//  TransformationDemo
//
//  Created by Benedict Cohen on 26/12/2011.
//  Copyright (c) 2011 Benedict Cohen. All rights reserved.
//

#import "CATransform3DFieldAccessors.h"

const CATransform3DField CATransform3DFields[] = 
{CATransform3DFieldM11, CATransform3DFieldM12, CATransform3DFieldM13, CATransform3DFieldM14,    
    CATransform3DFieldM21, CATransform3DFieldM22, CATransform3DFieldM23, CATransform3DFieldM24,        
    CATransform3DFieldM31, CATransform3DFieldM32, CATransform3DFieldM33, CATransform3DFieldM34,        
    CATransform3DFieldM41, CATransform3DFieldM42, CATransform3DFieldM43, CATransform3DFieldM44};

const CFIndex CATransform3DDimensionLength = 4;


CATransform3D CATransform3DSetField(CATransform3D transform, CATransform3DField field, CGFloat value)

{
    switch (field)
    {
        case CATransform3DFieldM11: transform.m11 = value; break; 
        case CATransform3DFieldM12: transform.m12 = value; break;
        case CATransform3DFieldM13: transform.m13 = value; break;
        case CATransform3DFieldM14: transform.m14 = value; break;
            
        case CATransform3DFieldM21: transform.m21 = value; break;
        case CATransform3DFieldM22: transform.m22 = value; break;
        case CATransform3DFieldM23: transform.m23 = value; break;
        case CATransform3DFieldM24: transform.m24 = value; break;
            
        case CATransform3DFieldM31: transform.m31 = value; break;
        case CATransform3DFieldM32: transform.m32 = value; break;
        case CATransform3DFieldM33: transform.m33 = value; break;
        case CATransform3DFieldM34: transform.m34 = value; break;
            
        case CATransform3DFieldM41: transform.m41 = value; break;
        case CATransform3DFieldM42: transform.m42 = value; break;
        case CATransform3DFieldM43: transform.m43 = value; break;
        case CATransform3DFieldM44: transform.m44 = value; break;
    }    
    
    return transform;
}



CGFloat CATransform3DFieldValue(CATransform3D transform, CATransform3DField field)
{
    switch (field)
    {
        case CATransform3DFieldM11: return transform.m11;
        case CATransform3DFieldM12: return transform.m12;
        case CATransform3DFieldM13: return transform.m13;
        case CATransform3DFieldM14: return transform.m14;
            
        case CATransform3DFieldM21: return transform.m21;
        case CATransform3DFieldM22: return transform.m22;
        case CATransform3DFieldM23: return transform.m23;
        case CATransform3DFieldM24: return transform.m24;
            
        case CATransform3DFieldM31: return transform.m31;
        case CATransform3DFieldM32: return transform.m32;
        case CATransform3DFieldM33: return transform.m33;
        case CATransform3DFieldM34: return transform.m34;
            
        case CATransform3DFieldM41: return transform.m41;
        case CATransform3DFieldM42: return transform.m42;
        case CATransform3DFieldM43: return transform.m43;
        case CATransform3DFieldM44: return transform.m44;
    }    
}
