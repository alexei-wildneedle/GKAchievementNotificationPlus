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


static GKAchievementNotificationPlusDefaults defaults;


#define GKNotificationScaleFactor() ([[self class] defaults].fakePad ? ABUniversalScaleFactor() : 1)


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
#pragma mark Defaults Methods

+ (void) initialize
{
    [[self class] setDefaults];
}

+ (void) setDefaults
{
    defaults.fakePad = YES;

    defaults.backgroundGraphic = @"gk-notification.png";
    defaults.backgroundGraphicLeftCapWidth = 8.0f;
    defaults.hasShadow = NO;
    //defaults.shadowOffset = CGPointMake(3, 3);
    //defaults.shadowAlpha = 0.5f;
    //defaults.shadowCornerRounding = 5.0f;

    defaults.defaultSize = CGSizeMake(284, 52);
    defaults.isCentered = YES;
    defaults.setToOutOrigin = CGPointMake(0, 5);

    defaults.animationTime = 0.4f;
    defaults.displayTime = 1.75f;

    defaults.text1Color[0] = 0xff/(CGFloat)0xff;
    defaults.text1Color[1] = 0xff/(CGFloat)0xff;
    defaults.text1Color[2] = 0xff/(CGFloat)0xff;
    defaults.text1Size = 15.0f;
    defaults.text2Color[0] = 0xff/(CGFloat)0xff;
    defaults.text2Color[1] = 0xff/(CGFloat)0xff;
    defaults.text2Color[2] = 0xff/(CGFloat)0xff;
    defaults.text2Size = 11.0f;

    defaults.text1Font = @"HelveticaNeue-Bold";
    defaults.text2Font = @"HelveticaNeue";

    defaults.text1Frame = CGRectMake(10.0, 6.0f, 264.0f, 22.0f);
    defaults.text2Frame = CGRectMake(10.0, 20.0f, 264.0f, 22.0f);
    defaults.text1WithImageFrame = CGRectMake(45.0, 6.0f, 229.0f, 22.0f);
    defaults.text2WithImageFrame = CGRectMake(45.0, 20.0f, 229.0f, 22.0f);

    defaults.iconCornerRadius = 5.0f;
}

+ (GKAchievementNotificationPlusDefaults) defaults
{
    return defaults;
}

#pragma mark -
#pragma mark Initializers

- (void) dealloc
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
                              [[self class] defaults].defaultSize.width*GKNotificationScaleFactor(),
                              [[self class] defaults].defaultSize.height*GKNotificationScaleFactor());
    [self initWithFrame:frame title:achievement.title message:achievement.achievedDescription image:achievement.image];
    return self;
}

- (id) initWithTitle:(NSString*)title message:(NSString*)message image:(UIImage*)image
{
    CGRect frame = CGRectMake(0,
                              0,
                              [[self class] defaults].defaultSize.width*GKNotificationScaleFactor(),
                              [[self class] defaults].defaultSize.height*GKNotificationScaleFactor());
    [self initWithFrame:frame title:title message:message image:image];
    return self;
}

- (id) initWithFrame:(CGRect)frame title:(NSString*)title message:(NSString*)message image:(UIImage*)image
{
    if ((self = [super initWithFrame:frame]))
    {
        self.background = [self generateBackground];

        if ([[self class] defaults].hasShadow == YES)
        {

            self.shadow = [self generateShadow];
        }

        self.textLabel = [self generateTitleLabel];
        self.detailLabel = [self generateMessageLabel];

        [self addSubview:self.shadow];
        [self addSubview:self.background];
        [self addSubview:self.textLabel];
        [self addSubview:self.detailLabel];

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
    }

    return self;
}

- (UIImageView*) generateBackground
{
    UIImage* initialImage = nil;
    if ([[self class] defaults].fakePad && (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad))
    {
        initialImage = [UIImage imageWithContentsOfFileUsingRetinaAt1xScale:[[NSBundle mainBundle] pathForResource:[[self class] defaults].backgroundGraphic ofType:nil]];
    }
    else
    {
        initialImage = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[[self class] defaults].backgroundGraphic ofType:nil]];
    }
    UIImage *backgroundStretch = [initialImage
                                  stretchableImageWithLeftCapWidth:[[self class] defaults].backgroundGraphicLeftCapWidth*GKNotificationScaleFactor()
                                  topCapHeight:0.0f];
    UIImageView *tBackground = [[UIImageView alloc] initWithFrame:self.frame];
    tBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    tBackground.image = backgroundStretch;
    self.opaque = NO;
    return [tBackground autorelease];
}

- (UIView*) generateShadow
{
    CGRect shadowFrame = self.frame;
    shadowFrame.origin = CGPointMake(shadowFrame.origin.x+[[self class] defaults].shadowOffset.x*GKNotificationScaleFactor(),
                                     shadowFrame.origin.y+[[self class] defaults].shadowOffset.y*GKNotificationScaleFactor());
    UIView* shadow = [[UIView alloc] initWithFrame:shadowFrame];
    shadow.backgroundColor = [UIColor blackColor];
    shadow.alpha = [[self class] defaults].shadowAlpha;
    shadow.layer.cornerRadius = [[self class] defaults].shadowCornerRadius*GKNotificationScaleFactor();
    return [shadow autorelease];
}

- (UILabel*) generateTitleLabel
{
    CGRect r1 = CGRectMultiply([[self class] defaults].text1Frame, GKNotificationScaleFactor());
    UILabel *tTextLabel = [[UILabel alloc] initWithFrame:r1];
    tTextLabel.textAlignment = UITextAlignmentCenter;
    tTextLabel.adjustsFontSizeToFitWidth = NO;
    tTextLabel.backgroundColor = [UIColor clearColor];
    tTextLabel.textColor = [UIColor colorWithRed:[[self class] defaults].text1Color[0]
                                           green:[[self class] defaults].text1Color[1]
                                            blue:[[self class] defaults].text1Color[2]
                                           alpha:1.0f];
    tTextLabel.font = [UIFont fontWithName:[[self class] defaults].text1Font size:[[self class] defaults].text1Size*GKNotificationScaleFactor()];
    tTextLabel.text = NSLocalizedString(@"Achievement Unlocked", @"Achievemnt Unlocked Message");
    return [tTextLabel autorelease];
}

- (UILabel*) generateMessageLabel
{
    CGRect r2 = CGRectMultiply([[self class] defaults].text2Frame, GKNotificationScaleFactor());
    UILabel *tDetailLabel = [[UILabel alloc] initWithFrame:r2];
    tDetailLabel.textAlignment = UITextAlignmentCenter;
    tDetailLabel.adjustsFontSizeToFitWidth = NO;
    tDetailLabel.backgroundColor = [UIColor clearColor];
    tDetailLabel.textColor = [UIColor colorWithRed:[[self class] defaults].text2Color[0]
                                             green:[[self class] defaults].text2Color[1]
                                              blue:[[self class] defaults].text2Color[2]
                                             alpha:1.0f];
    tDetailLabel.font = [UIFont fontWithName:[[self class] defaults].text2Font size:[[self class] defaults].text2Size*GKNotificationScaleFactor()];
    return [tDetailLabel autorelease];
}

- (UIImageView*) generateLogo
{
    UIImageView *tLogo = [[UIImageView alloc] initWithFrame:CGRectMultiply(CGRectMake(7.0f, 6.0f, 34.0f, 34.0f), GKNotificationScaleFactor())];
    tLogo.contentMode = UIViewContentModeScaleAspectFill;
    tLogo.layer.cornerRadius = [[self class] defaults].iconCornerRadius*GKNotificationScaleFactor();
    tLogo.layer.masksToBounds = YES;
    return [tLogo autorelease];
}

- (void) setImage:(UIImage*)image
{
    if (image)
    {
        if (!self.logo)
        {
            self.logo = [self generateLogo];
            [self addSubview:self.logo];
        }
        self.logo.image = image;
        self.textLabel.frame = CGRectMultiply([[self class] defaults].text1WithImageFrame, GKNotificationScaleFactor());
        self.detailLabel.frame = CGRectMultiply([[self class] defaults].text2WithImageFrame, GKNotificationScaleFactor());
    }
    else
    {
        if (self.logo)
        {
            [self.logo removeFromSuperview];
        }
        self.textLabel.frame = CGRectMultiply([[self class] defaults].text1Frame, GKNotificationScaleFactor());
        self.detailLabel.frame = CGRectMultiply([[self class] defaults].text2Frame, GKNotificationScaleFactor());
    }
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

    if ([[self class] defaults].isCentered == YES)
    {
        frame.origin = CGPointMake((self.superview.bounds.size.width-frame.size.width)/2.0f, [[self class] defaults].setToOutOrigin.y*GKNotificationScaleFactor());
    }
    else
    {
        frame.origin = CGPointMake([[self class] defaults].setToOutOrigin.x*GKNotificationScaleFactor(), [[self class] defaults].setToOutOrigin.y*GKNotificationScaleFactor());
    }

    self.frame = frame;
}

- (void) setToOut
{
    CGRect frame = self.frame;

    if ([[self class] defaults].isCentered == YES)
    {
        frame.origin = CGPointMake((self.superview.bounds.size.width-frame.size.width)/2.0f, -self.bounds.size.height);
    }
    else
    {
        frame.origin = CGPointMake([[self class] defaults].setToOutOrigin.x*GKNotificationScaleFactor(), -self.bounds.size.height);
    }

    self.frame = frame;
}

- (void)animateIn
{
    [self delegateCallback:@selector(willShowAchievementNotification:) withObject:self];
    [self willShowActions];
    [self setToOut];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[self class] defaults].animationTime];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDidStopSelector:@selector(animationInDidStop:finished:context:)];
    [self setToIn];
    [UIView commitAnimations];
}

- (void)animateOut
{
    [self delegateCallback:@selector(willHideAchievementNotification:) withObject:self];
    [self willHideActions];
    [self setToIn];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:[[self class] defaults].animationTime];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDidStopSelector:@selector(animationOutDidStop:finished:context:)];
    [self setToOut];
    [UIView commitAnimations];
}

- (void)animationInDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self delegateCallback:@selector(didShowAchievementNotification:) withObject:self];
    [self didShowActions];
    [self performSelector:@selector(animateOut) withObject:nil afterDelay:[[self class] defaults].displayTime];
}

- (void)animationOutDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [self delegateCallback:@selector(didHideAchievementNotification:) withObject:self];
    [self didHideActions];
    [self removeFromSuperview];
}

- (void) willShowActions {}
- (void) didShowActions {}
- (void) willHideActions {}
- (void) didHideActions {}

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

@end
