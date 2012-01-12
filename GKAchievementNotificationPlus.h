//
//  GKAchievementNotificationPlus.h
//
//  Created by Benjamin Borowski on 9/30/10.
//  Copyright 2010 Typeoneerror Studios. All rights reserved.
//
//  Modified by Alexei Baboulevitch on 1/11/12.
//  Copyright 2012 Wild Needle. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>

@class GKAchievementNotificationPlus;


// TODO: move to center on rotation
// TODO: add note about universal scale factor


struct GKAchievementNotificationPlusDefaults
{
    BOOL fakePad; // multiplies all the point values by 2 and uses the @2x graphics if on iPad

    NSString* backgroundGraphic;
    CGFloat backgroundGraphicLeftCapWidth;
    BOOL hasShadow;
    CGPoint shadowOffset;
    CGFloat shadowAlpha;
    CGFloat shadowCornerRadius;

    CGSize defaultSize;
    BOOL isCentered; // if this is set to YES, the x coordinate of kGKAchievementNotificationPlusSetToOutOrigin is ignored
    CGPoint setToOutOrigin;

    CGFloat animationTime;
    CGFloat displayTime;

    CGFloat text1Color[3];
    CGFloat text1Size;
    CGFloat text2Color[3];
    CGFloat text2Size;

    NSString* text1Font;
    NSString* text2Font;

    CGRect text1Frame;
    CGRect text2Frame;
    CGRect text1WithImageFrame;
    CGRect text2WithImageFrame;

    CGFloat iconCornerRadius;
};
typedef struct GKAchievementNotificationPlusDefaults GKAchievementNotificationPlusDefaults;


/**
 * The handler delegate responds to hiding and showing
 * of the game center notifications.
 */
@protocol GKAchievementNotificationPlusDelegate <NSObject>

@optional

/**
 * Called on delegate when notification is hidden.
 * @param nofification  The notification view that was hidden.
 */
- (void)didHideAchievementNotification:(GKAchievementNotificationPlus *)notification;

/**
 * Called on delegate when notification is shown.
 * @param nofification  The notification view that was shown.
 */
- (void)didShowAchievementNotification:(GKAchievementNotificationPlus *)notification;

/**
 * Called on delegate when notification is about to be hidden.
 * @param nofification  The notification view that will be hidden.
 */
- (void)willHideAchievementNotification:(GKAchievementNotificationPlus *)notification;

/**
 * Called on delegate when notification is about to be shown.
 * @param nofification  The notification view that will be shown.
 */
- (void)willShowAchievementNotification:(GKAchievementNotificationPlus *)notification;

@end


/**
 * The GKAchievementNotification is a view for showing the achievement earned.
 */
@interface GKAchievementNotificationPlus : UIView
{
    NSString *_message;  /**< Optional custom achievement message. */
    NSString *_title;    /**< Optional custom achievement title. */

    UIImageView  *_background;  /**< Stretchable background view. */
    UIImageView  *_logo;        /**< Logo that is displayed on the left. */
    UIView* _shadow;

    UILabel      *_textLabel;    /**< Text label used to display achievement title. */
    UILabel      *_detailLabel;  /**< Text label used to display achievement description. */

    id<GKAchievementNotificationPlusDelegate> _handlerDelegate;  /**< Reference to nofification handler. */
}

/** Optional custom achievement message. */
@property (nonatomic, retain) NSString *message;
// Shadow that stays under the message box.
@property (nonatomic, retain) UIView* shadow;
/** Optional custom achievement title. */
@property (nonatomic, retain) NSString *title;
/** Stretchable background view. */
@property (nonatomic, retain) UIImageView *background;
/** Logo that is displayed on the left. */
@property (nonatomic, retain) UIImageView *logo;
/** Text label used to display achievement title. */
@property (nonatomic, retain) UILabel *textLabel;
/** Text label used to display achievement description. */
@property (nonatomic, retain) UILabel *detailLabel;
/** Reference to nofification handler. */
@property (nonatomic, retain) id<GKAchievementNotificationPlusDelegate> handlerDelegate;

+ (id) achievementNotificationWithDescription:(GKAchievementDescription*)achievement;
+ (id) achievementNotificationWithTitle:(NSString*)title message:(NSString*)message image:(UIImage*)image;
- (id) initWithDescription:(GKAchievementDescription*)achievement;
- (id) initWithTitle:(NSString*)title message:(NSString*)message image:(UIImage*)image;

- (void) setImage:(UIImage*)image;

// Animate the achievement notification onto the current window, then animate out. Similar to UIAlertView's show method.
- (void) show;

// Manually set or animate to in or out position.
- (void) setToIn;
- (void) setToOut;
- (void)animateIn;
- (void)animateOut;

// The methods below are all for overriding in subclasses.

// To override the default config in a subclass, create a static GKAchievementNotificationPlusDefaults and override the two methods below.
// setDefaults should set all the struct variables, and defaults should return the static variable.
+ (void) setDefaults;
+ (GKAchievementNotificationPlusDefaults) defaults;

// Override these methods to create custom graphics. Do not call manually.
- (UIImageView*) generateBackground;
- (UIView*) generateShadow;
- (UILabel*) generateTitleLabel;
- (UILabel*) generateMessageLabel;
- (UIImageView*) generateLogo;

// Override these methods to perform actions at certain points during the animation. Correspond to delegate callbacks. Defaults do nothing.
- (void) willShowActions;
- (void) didShowActions;
- (void) willHideActions;
- (void) didHideActions;

@end
