@class HBTSStatusBarView;

typedef enum {
	HBTSStatusBarTypeTyping,
	HBTSStatusBarTypeRead
} HBTSStatusBarType;

void HBTSSetStatusBar(HBTSStatusBarType type, NSString *string, BOOL typing);

NSBundle *prefsBundle;
HBTSStatusBarView *overlayView;

HBTSStatusBarType currentType;
NSString *currentName;
BOOL currentTyping;

#define IN_SPRINGBOARD ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.springboard"])
#define I18N(key) ([prefsBundle localizedStringForKey:key value:key table:@"TypeStatus"])
