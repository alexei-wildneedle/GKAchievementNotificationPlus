//
//  ABUtils.m
//  GKAchievementHandlerPlusTest
//
//  Created by Alexei Baboulevitch on 1/11/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ABUtils.h"

inline NSUInteger ABUniversalScaleFactor(void)
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

inline CGRect CGRectMultiply(CGRect rect, CGFloat scalar)
{
    return CGRectMake(rect.origin.x*scalar, rect.origin.y*scalar, rect.size.width*scalar, rect.size.height*scalar);
}
