@class HBTSStatusBarView;

typedef enum {
	HBTSStatusBarTypeTyping,
	HBTSStatusBarTypeRead
} HBTSStatusBarType;

void HBTSSetStatusBar(HBTSStatusBarType type, NSString *string, BOOL typing);

NSBundle *prefsBundle;
HBTSStatusBarView *overlayView;

#define I18N(key) ([prefsBundle localizedStringForKey:key value:key table:@"TypeStatus"])
