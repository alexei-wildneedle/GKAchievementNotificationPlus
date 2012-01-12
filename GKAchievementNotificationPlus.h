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
    GKAchievementDescription  *_achievement;  /**< Description of achievement earned. */

    NSString *_message;  /**< Optional custom achievement message. */
    NSString *_title;    /**< Optional custom achievement title. */

    UIImageView  *_background;  /**< Stretchable background view. */
    UIImageView  *_logo;        /**< Logo that is displayed on the left. */

    UILabel      *_textLabel;    /**< Text label used to display achievement title. */
    UILabel      *_detailLabel;  /**< Text label used to display achievement description. */

    id<GKAchievementNotificationPlusDelegate> _handlerDelegate;  /**< Reference to nofification handler. */
}

/** Description of achievement earned. */
@property (nonatomic, retain) GKAchievementDescription *achievement;
/** Optional custom achievement message. */
@property (nonatomic, retain) NSString *message;
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

// Sets up the default configuration constants for this class. Override in subclass if you want your own behaviors.
// Another approach would be to have an instance-specific container property or several properties that would then
// update the layout if changed, but this method should cover most use cases.
+ (void) setDefaults;

- (GKAchievementNotificationPlus*) achievementNotificationWithDescription:(GKAchievementDescription*)achievement;
- (GKAchievementNotificationPlus*) achievementNotificationWithTitle:(NSString*)title message:(NSString*)message image:(UIImage*)image;

- (id) initWithDescription:(GKAchievementDescription*)achievement;
- (id) initWithTitle:(NSString*)title message:(NSString*)message image:(UIImage*)image;

// Animate the achievement notification onto the current window, then animate out. Similar to UIAlertView's show method.
- (void) show;

// Manually set or animate to in or out position.
- (void) setToIn;
- (void) setToOut;
- (void)animateIn;
- (void)animateOut;

/**
 * Change the logo that appears on the left.
 * @param image  The image to display.
 */
- (void)setImage:(UIImage *)image;

@end
