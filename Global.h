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

NSBundle *prefsBundle;

#ifdef IN_SPRINGBOARD
#undef IN_SPRINGBOARD
#endif

#define IN_SPRINGBOARD (SPRINGBOARD || [[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"])
#define L18N(key) ([prefsBundle localizedStringForKey:key value:key table:@"TypeStatus"])
#define GET_BOOL(key, default) (prefs[key] ? ((NSNumber *)prefs[key]).boolValue : default)
#define GET_FLOAT(key, default) (prefs[key] ? ((NSNumber *)prefs[key]).floatValue : default)

#if !PREFERENCES
static NSTimeInterval const kHBTSTypingTimeout = 60.0;

/*
 old notification name is used here for compatibility with
 tweaks that listen into typestatus' notifications
*/

static NSString *const HBTSClientSetStatusBarNotification = @"HBTSClientSetStatusBar";
static NSString *const HBTSSpringBoardReceivedMessageNotification = @"HBTSSpringBoardReceivedMessageNotification";

#pragma mark - Preferences

BOOL firstLoad = YES;
BOOL overlaySlide = YES;
BOOL overlayFade = YES;
CGFloat overlayDuration = 5.f;
BOOL typingStatus = YES;
BOOL typingTimeout = NO;
BOOL readStatus = YES;

#if SPRINGBOARD
BOOL typingHideInMessages = YES;
BOOL typingIcon = NO;
BOOL readHideInMessages = YES;
BOOL shouldUndim = YES;
BOOL useBulletin = YES;
#endif

#if !SPRINGBOARD && !IMAGENT
HBTSStatusBarView *overlayView;
#endif
#endif
#endif
