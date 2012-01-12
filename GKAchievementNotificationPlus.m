//
//  GKAchievementNotificationPlus.m
//
//  Created by Benjamin Borowski on 9/30/10.
//  Copyright 2010 Typeoneerror Studios. All rights reserved.
//
//  Modified by Alexei Baboulevitch on 1/11/12.
//  Copyright 2012 Wild Needle. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "GKAchievementNotificationPlus.h"
#import "ABUtils.h"
#import "UIImage+2xLoading.h"


// TODO: add note about universal scale factor
// TODO: this constant system sucks, revise

BOOL kGKAchievementNotificationPlusFakePad; // multiplies all the point values by 2 and uses the @2x graphics if on iPad

NSString* kGKAchievementNotificationPlusBackgroundGraphic;
CGFloat kGKAchievementNotificationPlusBackgroundGraphicLeftCapWidth;
BOOL kGKAchievementNotificationPlusHasShadow;
CGPoint kGKAchievementNotificationPlusShadowOffset;
CGFloat kGKAchievementNotificationPlusShadowAlpha;
CGFloat kGKAchievementNotificationPlusShadowCornerRounding;

CGSize kGKAchievementNotificationPlusDefaultSize;
BOOL kGKAchievementNotificationPlusIsCentered; // if this is set to YES, the x coordinate of kGKAchievementNotificationPlusSetToOutOrigin is ignored
CGPoint kGKAchievementNotificationPlusSetToOutOrigin;

CGFloat kGKAchievementNotificationPlusAnimationTime;
CGFloat kGKAchievementNotificationPlusDisplayTime;

CGFloat kGKAchievementNotificationPlusText1Color[3];
CGFloat kGKAchievementNotificationPlusText1Size;
CGFloat kGKAchievementNotificationPlusText2Color[3];
CGFloat kGKAchievementNotificationPlusText2Size;

CGRect kGKAchievementNotificationPlusText1;
CGRect kGKAchievementNotificationPlusText2;
CGRect kGKAchievementNotificationPlusText1WLogo;
CGRect kGKAchievementNotificationPlusText2WLogo;


static inline NSUInteger GKNotificationScaleFactor(void)
{
    return (kGKAchievementNotificationPlusFakePad ? ABUniversalScaleFactor() : 1);
}


@interface GKAchievementNotificationPlus ()

- (id) initWithFrame:(CGRect)frame title:(NSString*)title message:(NSString*)message image:(UIImage*)image; // designated initializer
- (void)animationInDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)animationOutDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)delegateCallback:(SEL)selector withObject:(id)object;

@end


@implementation GKAchievementNotificationPlus

@synthesize background=_background;
@synthesize shadow = _shadow;
@synthesize handlerDelegate=_handlerDelegate;
@synthesize detailLabel=_detailLabel;
@synthesize logo=_logo;
@synthesize message=_message;
@synthesize title=_title;
@synthesize textLabel=_textLabel;

#pragma mark -
#pragma mark Static Methods

+ (void) initialize
{
    [[self class] setDefaults];
}

+ (void) setDefaults
{
    kGKAchievementNotificationPlusFakePad = YES;

    kGKAchievementNotificationPlusBackgroundGraphic = @"gk-notification.png";
    kGKAchievementNotificationPlusBackgroundGraphicLeftCapWidth = 8.0f;
    kGKAchievementNotificationPlusHasShadow = NO;
    //kGKAchievementNotificationPlusShadowOffset = CGPointMake(3, 3);
    //kGKAchievementNotificationPlusShadowAlpha = 0.5f;
    //kGKAchievementNotificationPlusShadowCornerRounding = 5.0f;

    kGKAchievementNotificationPlusDefaultSize = CGSizeMake(284, 52);
    kGKAchievementNotificationPlusIsCentered = YES;
    kGKAchievementNotificationPlusSetToOutOrigin = CGPointMake(0, 5);

    kGKAchievementNotificationPlusAnimationTime = 0.4f;
    kGKAchievementNotificationPlusDisplayTime = 1.75f;

    kGKAchievementNotificationPlusText1Color[0] = 0xff/(CGFloat)0xff;
    kGKAchievementNotificationPlusText1Color[1] = 0xff/(CGFloat)0xff;
    kGKAchievementNotificationPlusText1Color[2] = 0xff/(CGFloat)0xff;
    kGKAchievementNotificationPlusText1Size = 15.0f;
    kGKAchievementNotificationPlusText2Color[0] = 0xff/(CGFloat)0xff;
    kGKAchievementNotificationPlusText2Color[1] = 0xff/(CGFloat)0xff;
    kGKAchievementNotificationPlusText2Color[2] = 0xff/(CGFloat)0xff;
    kGKAchievementNotificationPlusText2Size = 11.0f;

    kGKAchievementNotificationPlusText1 = CGRectMake(10.0, 6.0f, 264.0f, 22.0f);
    kGKAchievementNotificationPlusText2 = CGRectMake(10.0, 20.0f, 264.0f, 22.0f);
    kGKAchievementNotificationPlusText1WLogo = CGRectMake(45.0, 6.0f, 229.0f, 22.0f);
    kGKAchievementNotificationPlusText2WLogo = CGRectMake(45.0, 20.0f, 229.0f, 22.0f);
}

#pragma mark -
#pragma mark Initializers

+ (id) achievementNotificationWithDescription:(GKAchievementDescription*)achievement
{
    GKAchievementNotificationPlus* result = [[GKAchievementNotificationPlus alloc] initWithDescription:achievement];
    return [result autorelease];
}

+ (id) achievementNotificationWithTitle:(NSString*)title message:(NSString*)message image:(UIImage*)image
{
    GKAchievementNotificationPlus* result = [[GKAchievementNotificationPlus alloc] initWithTitle:(NSString*)title message:(NSString*)message image:(UIImage*)image];
    return [result autorelease];
}

- (id) initWithDescription:(GKAchievementDescription*)achievement
{
    CGRect frame = CGRectMake(0,
                              0,
                              kGKAchievementNotificationPlusDefaultSize.width*GKNotificationScaleFactor(),
                              kGKAchievementNotificationPlusDefaultSize.height*GKNotificationScaleFactor());
    [self initWithFrame:frame title:achievement.title message:achievement.achievedDescription image:achievement.image];
    return self;
}

- (id) initWithTitle:(NSString*)title message:(NSString*)message image:(UIImage*)image
{
    CGRect frame = CGRectMake(0,
                              0,
                              kGKAchievementNotificationPlusDefaultSize.width*GKNotificationScaleFactor(),
                              kGKAchievementNotificationPlusDefaultSize.height*GKNotificationScaleFactor());
    [self initWithFrame:frame title:title message:message image:image];
    self.title = title;
    self.message = message;
    return self;
}

- (id) initWithFrame:(CGRect)frame title:(NSString*)title message:(NSString*)message image:(UIImage*)image
{
    if ((self = [super initWithFrame:frame]))
    {
        // create the GK background
        UIImage* initialImage = nil;
        if (kGKAchievementNotificationPlusFakePad && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone))
        {
            initialImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:kGKAchievementNotificationPlusBackgroundGraphic ofType:nil]];
        }
        else
        {
            initialImage = [UIImage imageWithContentsOfFileUsingRetinaAt1xScale:[[NSBundle mainBundle] pathForResource:kGKAchievementNotificationPlusBackgroundGraphic ofType:nil]];
        }
        UIImage *backgroundStretch = [initialImage
                                      stretchableImageWithLeftCapWidth:kGKAchievementNotificationPlusBackgroundGraphicLeftCapWidth*GKNotificationScaleFactor()
                                      topCapHeight:0.0f];
        UIImageView *tBackground = [[UIImageView alloc] initWithFrame:frame];
        tBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tBackground.image = backgroundStretch;
        self.background = tBackground;
        self.opaque = NO;
        [tBackground release];

        if (kGKAchievementNotificationPlusHasShadow == YES)
        {
            CGRect shadowFrame = frame;
            shadowFrame.origin = CGPointMake(shadowFrame.origin.x+kGKAchievementNotificationPlusShadowOffset.x*GKNotificationScaleFactor(),
                                             shadowFrame.origin.y+kGKAchievementNotificationPlusShadowOffset.y*GKNotificationScaleFactor());
            UIView* shadow = [[UIView alloc] initWithFrame:shadowFrame];
            shadow.backgroundColor = [UIColor blackColor];
            shadow.alpha = kGKAchievementNotificationPlusShadowAlpha;
            shadow.layer.cornerRadius = kGKAchievementNotificationPlusShadowCornerRounding*GKNotificationScaleFactor();
            self.shadow = shadow;
            [self addSubview:self.shadow];
        }

        [self addSubview:self.background];

        CGRect r1 = CGRectMultiply(kGKAchievementNotificationPlusText1, GKNotificationScaleFactor());
        CGRect r2 = CGRectMultiply(kGKAchievementNotificationPlusText2, GKNotificationScaleFactor());

        // create the text label
        UILabel *tTextLabel = [[UILabel alloc] initWithFrame:r1];
        tTextLabel.textAlignment = UITextAlignmentCenter;
        tTextLabel.adjustsFontSizeToFitWidth = NO;
        tTextLabel.backgroundColor = [UIColor clearColor];
        tTextLabel.textColor = [UIColor colorWithRed:kGKAchievementNotificationPlusText1Color[0]
                                               green:kGKAchievementNotificationPlusText1Color[1]
                                                blue:kGKAchievementNotificationPlusText1Color[2]
                                               alpha:1.0f];
        tTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:kGKAchievementNotificationPlusText1Size*GKNotificationScaleFactor()];
        tTextLabel.text = NSLocalizedString(@"Achievement Unlocked", @"Achievemnt Unlocked Message");
        self.textLabel = tTextLabel;
        [tTextLabel release];

        // detail label
        UILabel *tDetailLabel = [[UILabel alloc] initWithFrame:r2];
        tDetailLabel.textAlignment = UITextAlignmentCenter;
        tDetailLabel.adjustsFontSizeToFitWidth = NO;
        tDetailLabel.backgroundColor = [UIColor clearColor];
        tDetailLabel.textColor = [UIColor colorWithRed:kGKAchievementNotificationPlusText2Color[0]
                                                 green:kGKAchievementNotificationPlusText2Color[1]
                                                  blue:kGKAchievementNotificationPlusText2Color[2]
                                                 alpha:1.0f];
        tDetailLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:kGKAchievementNotificationPlusText2Size*GKNotificationScaleFactor()];
        self.detailLabel = tDetailLabel;
        [tDetailLabel release];

        if (title)
        {
            self.title = title;
            self.textLabel.text = self.title;
        }
        if (message)
        {
            self.message = message;
            self.detailLabel.text = self.message;
        }
        if (image)
        {
            [self setImage:image];
        }

        [self addSubview:self.textLabel];
        [self addSubview:self.detailLabel];
    }

    return self;
}

- (void)dealloc
{
    self.handlerDelegate = nil;
    self.logo = nil;

    [_background release];
    [_shadow release];
    [_detailLabel release];
    [_logo release];
    [_message release];
    [_textLabel release];
    [_title release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark Animation and Display Methods

- (void) show
{
    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
    [(UIView*)[[currentWindow subviews] objectAtIndex:0] addSubview:self]; //according to StackOverflow, only the first view responds to rotations
    [self animateIn];
}

- (void) setToIn
{
    CGRect frame = self.frame;

    if (kGKAchievementNotificationPlusIsCentered == YES)
    {
        frame.origin = CGPointMake((self.superview.bounds.size.width-frame.size.width)/2.0f, kGKAchievementNotificationPlusSetToOutOrigin.y*GKNotificationScaleFactor());
    }
    else
    {
        frame.origin = CGPointMake(kGKAchievementNotificationPlusSetToOutOrigin.x*GKNotificationScaleFactor(), kGKAchievementNotificationPlusSetToOutOrigin.y*GKNotificationScaleFactor());
    }

    self.frame = frame;
}

- (void) setToOut
{
    CGRect frame = self.frame;

    if (kGKAchievementNotificationPlusIsCentered == YES)
    {
        frame.origin = CGPointMake((self.superview.bounds.size.width-frame.size.width)/2.0f, -self.bounds.size.height);
    }
    else
    {
        frame.origin = CGPointMake(kGKAchievementNotificationPlusSetToOutOrigin.x*GKNotificationScaleFactor(), -self.bounds.size.height);
    }

    self.frame = frame;
}

- (void)animateIn
{
    [self delegateCallback:@selector(willShowAchievementNotification:) withObject:self];
    [self setToOut];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kGKAchievementNotificationPlusAnimationTime];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDidStopSelector:@selector(animationInDidStop:finished:context:)];
    [self setToIn];
    [UIView commitAnimations];
}

- (void)animateOut
{
    [self delegateCallback:@selector(willHideAchievementNotification:) withObject:self];
    [self setToIn];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:kGKAchievementNotificationPlusAnimationTime];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDidStopSelector:@selector(animationOutDidStop:finished:context:)];
    [self setToOut];
    [UIView commitAnimations];
}

- (void)animationInDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self delegateCallback:@selector(didShowAchievementNotification:) withObject:self];
    [self performSelector:@selector(animateOut) withObject:nil afterDelay:kGKAchievementNotificationPlusDisplayTime];
}

- (void)animationOutDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self delegateCallback:@selector(didHideAchievementNotification:) withObject:self];
    [self removeFromSuperview];
}

- (void)delegateCallback:(SEL)selector withObject:(id)object
{
    if (self.handlerDelegate)
    {
        if ([self.handlerDelegate respondsToSelector:selector])
        {
            [self.handlerDelegate performSelector:selector withObject:object];
        }
    }
}

#pragma mark -

- (void)setImage:(UIImage *)image
{
    if (image)
    {
        if (!self.logo)
        {
            UIImageView *tLogo = [[UIImageView alloc] initWithFrame:CGRectMultiply(CGRectMake(7.0f, 6.0f, 34.0f, 34.0f), GKNotificationScaleFactor())];
            tLogo.contentMode = UIViewContentModeCenter;
            self.logo = tLogo;
            [tLogo release];
            [self addSubview:self.logo];
        }
        self.logo.image = image;
        self.textLabel.frame = CGRectMultiply(kGKAchievementNotificationPlusText1WLogo, GKNotificationScaleFactor());
        self.detailLabel.frame = CGRectMultiply(kGKAchievementNotificationPlusText2WLogo, GKNotificationScaleFactor());
    }
    else
    {
        if (self.logo)
        {
            [self.logo removeFromSuperview];
        }
        self.textLabel.frame = CGRectMultiply(kGKAchievementNotificationPlusText1, GKNotificationScaleFactor());
        self.detailLabel.frame = CGRectMultiply(kGKAchievementNotificationPlusText2, GKNotificationScaleFactor());
    }
}

@end
