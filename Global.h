typedef enum {
	HBTSStatusBarTypeTyping,
	HBTSStatusBarTypeRead
} HBTSStatusBarType;

NSBundle *prefsBundle;

#define I18N(key) ([prefsBundle localizedStringForKey:key value:key table:@"TypeStatus"])
