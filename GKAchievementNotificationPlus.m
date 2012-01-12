//
//  GKAchievementNotificationPlus.m
//
//  Created by Benjamin Borowski on 9/30/10.
//  Copyright 2010 Typeoneerror Studios. All rights reserved.
//
//  Modified by Alexei Baboulevitch on 1/11/12.
//  Copyright 2012 Wild Needle. All rights reserved.
//

#import "GKAchievementNotificationPlus.h"


static CGSize kGKAchievementNotificationPlusDefaultSize;
static BOOL kGKAchievementNotificationPlusIsCentered; // if this is set to YES, the x coordinate of kGKAchievementNotificationPlusSetToOutOrigin is ignored
static CGPoint kGKAchievementNotificationPlusSetToOutOrigin;

static CGFloat kGKAchievementNotificationPlusAnimationTime;
static CGFloat kGKAchievementNotificationPlusDisplayTime;

static CGRect kGKAchievementNotificationPlusText1;
static CGRect kGKAchievementNotificationPlusText2;
static CGRect kGKAchievementNotificationPlusText1WLogo;
static CGRect kGKAchievementNotificationPlusText2WLogo;


@interface GKAchievementNotificationPlus ()

- (void)animationInDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)animationOutDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
- (void)delegateCallback:(SEL)selector withObject:(id)object;

@end


@implementation GKAchievementNotificationPlus

@synthesize achievement=_achievement;
@synthesize background=_background;
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
    kGKAchievementNotificationPlusDefaultSize = CGSizeMake(284, 52);
    kGKAchievementNotificationPlusIsCentered = YES;

    kGKAchievementNotificationPlusSetToOutOrigin = CGPointMake(0, 5);
    kGKAchievementNotificationPlusAnimationTime = 0.4f;
    kGKAchievementNotificationPlusDisplayTime = 1.75f;

    kGKAchievementNotificationPlusText1 = CGRectMake(10.0, 6.0f, 264.0f, 22.0f);
    kGKAchievementNotificationPlusText2 = CGRectMake(10.0, 20.0f, 264.0f, 22.0f);
    kGKAchievementNotificationPlusText1WLogo = CGRectMake(45.0, 6.0f, 229.0f, 22.0f);
    kGKAchievementNotificationPlusText2WLogo = CGRectMake(45.0, 20.0f, 229.0f, 22.0f);
}

#pragma mark -
#pragma mark Initializers

- (GKAchievementNotificationPlus*) achievementNotificationWithDescription:(GKAchievementDescription*)achievement
{
    GKAchievementNotificationPlus* result = [[GKAchievementNotificationPlus alloc] initWithDescription:achievement];
    return [result autorelease];
}

- (GKAchievementNotificationPlus*) achievementNotificationWithTitle:(NSString*)title message:(NSString*)message image:(UIImage*)image
{
    GKAchievementNotificationPlus* result = [[GKAchievementNotificationPlus alloc] initWithTitle:(NSString*)title message:(NSString*)message image:(UIImage*)image];
    return [result autorelease];
}

- (id) initWithDescription:(GKAchievementDescription*)achievement
{
    CGRect frame = CGRectMake(0, 0, kGKAchievementNotificationPlusDefaultSize.width, kGKAchievementNotificationPlusDefaultSize.height);
    [self initWithFrame:frame];
    self.achievement = achievement;
    return self;
}

- (id) initWithTitle:(NSString*)title message:(NSString*)message image:(UIImage*)image
{
    CGRect frame = CGRectMake(0, 0, kGKAchievementNotificationPlusDefaultSize.width, kGKAchievementNotificationPlusDefaultSize.height);
    [self initWithFrame:frame];
    self.title = title;
    self.message = message;
    return self;
}

- (id) initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        // create the GK background
        UIImage *backgroundStretch = [[UIImage imageNamed:@"gk-notification.png"] stretchableImageWithLeftCapWidth:8.0f topCapHeight:0.0f];
        UIImageView *tBackground = [[UIImageView alloc] initWithFrame:frame];
        tBackground.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        tBackground.image = backgroundStretch;
        self.background = tBackground;
        self.opaque = NO;
        [tBackground release];
        [self addSubview:self.background];

        CGRect r1 = kGKAchievementNotificationPlusText1;
        CGRect r2 = kGKAchievementNotificationPlusText2;

        // create the text label
        UILabel *tTextLabel = [[UILabel alloc] initWithFrame:r1];
        tTextLabel.textAlignment = UITextAlignmentCenter;
        tTextLabel.backgroundColor = [UIColor clearColor];
        tTextLabel.textColor = [UIColor whiteColor];
        tTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15.0f];
        tTextLabel.text = NSLocalizedString(@"Achievement Unlocked", @"Achievemnt Unlocked Message");
        self.textLabel = tTextLabel;
        [tTextLabel release];

        // detail label
        UILabel *tDetailLabel = [[UILabel alloc] initWithFrame:r2];
        tDetailLabel.textAlignment = UITextAlignmentCenter;
        tDetailLabel.adjustsFontSizeToFitWidth = YES;
        tDetailLabel.minimumFontSize = 10.0f;
        tDetailLabel.backgroundColor = [UIColor clearColor];
        tDetailLabel.textColor = [UIColor whiteColor];
        tDetailLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:11.0f];
        self.detailLabel = tDetailLabel;
        [tDetailLabel release];

        if (self.achievement)
        {
            self.textLabel.text = self.achievement.title;
            self.detailLabel.text = self.achievement.achievedDescription;
        }
        else
        {
            if (self.title)
            {
                self.textLabel.text = self.title;
            }
            if (self.message)
            {
                self.detailLabel.text = self.message;
            }
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
    
    [_achievement release];
    [_background release];
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
        frame.origin = CGPointMake((self.superview.bounds.size.width-frame.size.width)/2.0f, kGKAchievementNotificationPlusSetToOutOrigin.y);
    }
    else
    {
        frame.origin = CGPointMake(kGKAchievementNotificationPlusSetToOutOrigin.x, kGKAchievementNotificationPlusSetToOutOrigin.y);
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
        frame.origin = CGPointMake(kGKAchievementNotificationPlusSetToOutOrigin.x, -self.bounds.size.height);
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
            UIImageView *tLogo = [[UIImageView alloc] initWithFrame:CGRectMake(7.0f, 6.0f, 34.0f, 34.0f)];
            tLogo.contentMode = UIViewContentModeCenter;
            self.logo = tLogo;
            [tLogo release];
            [self addSubview:self.logo];
        }
        self.logo.image = image;
        self.textLabel.frame = kGKAchievementNotificationPlusText1WLogo;
        self.detailLabel.frame = kGKAchievementNotificationPlusText2WLogo;
    }
    else
    {
        if (self.logo)
        {
            [self.logo removeFromSuperview];
        }
        self.textLabel.frame = kGKAchievementNotificationPlusText1;
        self.detailLabel.frame = kGKAchievementNotificationPlusText2;
    }
}

@end
