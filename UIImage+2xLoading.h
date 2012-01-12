//
//  UIImage+2xLoading.h
//
//  Created by Alexei Baboulevitch on 8/11/11.
//  Copyright 2011 Wild Needle Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIImage (WNExtensionsUIImage2xLoading)

// Returns an @2x image at 1x scale factor if available. May be inefficient, since it creates a UIImage first
//	and then uses its CGImage to create another UIImage. If the CGImage is copied once it's passed to the
//	second UIImage, the image is loaded twice.
+ (id) imageWithContentsOfFileUsingRetinaAt1xScale:(NSString *)path;

// A convenience method that uses imageWithContentsOfFileUsingRetinaAt1xScale: if the device is an iPad,
//	and imageWithContentsOfFile: for everything else.
+ (id) imageWithContentsOfFileAutoSelect:(NSString*)path;

// Returns the same filename with "@2x" appended to the end, before the extension. Does not currently work
//	with files ending in ~iphone or ~ipad.
+ (NSString*) convertImageNameTo2x:(NSString*)filename;

@end
