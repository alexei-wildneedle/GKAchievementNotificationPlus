//
//  UIImage+2xLoading.m
//
//  Created by Alexei Baboulevitch on 8/11/11.
//  Copyright 2011 Wild Needle Inc. All rights reserved.
//

#import "UIImage+2xLoading.h"


@implementation UIImage (WNExtensionsUIImage2xLoading)

+ (id) imageWithContentsOfFileUsingRetinaAt1xScale:(NSString *)path
{
	path = [UIImage convertImageNameTo2x:path];
	UIImage* tempImage = [UIImage imageWithContentsOfFile:path];
	if([UIImage respondsToSelector:@selector(imageWithCGImage:scale:orientation:)]) {
		// 4.0+ devices, so set scale property manually
		return [UIImage imageWithCGImage:[tempImage CGImage] scale:1 orientation:UIImageOrientationUp];
	} else {
		// pre-4.0 devices, so UIImage doesn't support scale property; return image w/o any changes
		return tempImage;
	}
}

+ (id) imageWithContentsOfFileAutoSelect:(NSString*)path {
	if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
		return [UIImage imageWithContentsOfFile:path];
	} else {
		return [UIImage imageWithContentsOfFileUsingRetinaAt1xScale:path];
	}
}

+ (NSString*) convertImageNameTo2x:(NSString*)filename
{
	NSString* extension = [filename pathExtension];
	filename = [filename stringByDeletingPathExtension];
	if([filename hasSuffix:@"@2x"]) {
		return [filename stringByAppendingPathExtension:extension];
	} else {
		return [[filename stringByAppendingString:@"@2x"] stringByAppendingPathExtension:extension];
	}
}

@end
