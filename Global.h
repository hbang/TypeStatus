#ifndef _TYPESTATUS_GLOBAL_H
#define _TYPESTATUS_GLOBAL_H

@class HBTSStatusBarView;

#ifndef SPRINGBOARD
#define SPRINGBOARD 0
#endif

#ifndef IMAGENT
#define IMAGENT 0
#endif

#ifndef PREFERENCES
#define PREFERENCES 0
#endif

typedef enum {
	HBTSStatusBarTypeTyping,
	HBTSStatusBarTypeTypingEnded,
	HBTSStatusBarTypeRead
} HBTSStatusBarType;

#if SPRINGBOARD
void HBTSPostMessage(HBTSStatusBarType type, NSString *string, BOOL typing);
void HBTSTypingEnded();
#endif

#define L18N(key) ([prefsBundle localizedStringForKey:key value:key table:@"Root"])

#if !PREFERENCES
static NSTimeInterval const kHBTSTypingTimeout = 60.0;

/*
 old notification name is used here for compatibility with
 tweaks that listen into typestatus' notifications
*/

static NSString *const HBTSClientSetStatusBarNotification = @"HBTSClientSetStatusBar";
static NSString *const HBTSSpringBoardReceivedMessageNotification = @"HBTSSpringBoardReceivedMessageNotification";

static NSString *const kHBTSMessageTypeKey = @"Type";
static NSString *const kHBTSMessageSenderKey = @"Name";
static NSString *const kHBTSMessageIsTypingKey = @"Typing";
static NSString *const kHBTSMessageSendDateKey = @"Date";

#pragma mark - Preferences

static NSString *const kHBTSPreferencesDomain = @"ws.hbang.typestatus";

static NSString *const kHBTSPreferencesTypingStatusKey = @"TypingStatus";
static NSString *const kHBTSPreferencesTypingIconKey = @"TypingIcon";
static NSString *const kHBTSPreferencesTypingHideInMessagesKey = @"HideInMessages";
static NSString *const kHBTSPreferencesTypingTimeoutKey = @"TypingTimeout";

static NSString *const kHBTSPreferencesReadStatusKey = @"ReadStatus";
static NSString *const kHBTSPreferencesReadHideInMessagesKey = @"HideReadInMessages";

static NSString *const kHBTSPreferencesOverlayAnimationSlideKey = @"OverlaySlide";
static NSString *const kHBTSPreferencesOverlayAnimationFadeKey = @"OverlayFade";
static NSString *const kHBTSPreferencesOverlayDurationKey = @"OverlayDuration";

NSBundle *prefsBundle;
BOOL firstLoad = YES;
NSUserDefaults *userDefaults;

#if !SPRINGBOARD && !IMAGENT
HBTSStatusBarView *overlayView;
#endif
#endif
#endif
