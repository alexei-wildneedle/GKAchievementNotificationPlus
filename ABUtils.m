//
//  ABUtils.m
//
//  Created by Alexei Baboulevitch on 1/11/12.
//  Copyright 2012 Wild Needle Inc. All rights reserved.
//

#import "ABUtils.h"


NSUInteger ABUniversalScaleFactor(void)
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return 2;
    }
    else
    {
        return 1;
    }
}

CGRect ABRectMultiply(CGRect rect, CGFloat scalar)
{
    return CGRectMake(rect.origin.x*scalar, rect.origin.y*scalar, rect.size.width*scalar, rect.size.height*scalar);
}
