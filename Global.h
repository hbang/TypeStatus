@class HBTSStatusBarView;

#ifndef SPRINGBOARD
#define SPRINGBOARD 0
#endif

typedef enum {
	HBTSStatusBarTypeTyping,
	HBTSStatusBarTypeRead
} HBTSStatusBarType;

#import "HBTSStatusBarView.h"

#if SPRINGBOARD
void HBTSPostMessage(HBTSStatusBarType type, NSString *string, BOOL typing);
void HBTSTypingEnded();
#endif

NSBundle *prefsBundle;

#define IN_SPRINGBOARD ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"])
#define I18N(key) ([prefsBundle localizedStringForKey:key value:key table:@"TypeStatus"])
#define GET_BOOL(key, default) ([prefs objectForKey:key] ? ((NSNumber *)[prefs objectForKey:key]).boolValue : default)
#define GET_FLOAT(key, default) ([prefs objectForKey:key] ? ((NSNumber *)[prefs objectForKey:key]).floatValue : default)

#define kHBTSTypingTimeout 60

#pragma mark - Preferences

BOOL firstLoad = YES;
BOOL overlaySlide = YES;
BOOL overlayFade = YES;
float overlayDuration = 5.f;
BOOL typingStatus = YES;
BOOL typingTimeout = NO;
BOOL readStatus = YES;

#if SPRINGBOARD
BOOL typingHideInMessages = YES;
BOOL typingIcon = NO;
BOOL readHideInMessages = YES;
#else
HBTSStatusBarView *overlayView;
#endif
