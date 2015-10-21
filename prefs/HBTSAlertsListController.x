#import "HBTSAlertsListController.h"
#import <Preferences/PSSpecifier.h>
#import "../Client/HBTSPreferences.h"
#include <notify.h>

@implementation HBTSAlertsListController {
	HBTSPreferences *_preferences;
}

+ (NSString *)hb_specifierPlist {
	return @"Alerts";
}

#pragma mark - UIViewController

- (instancetype)init {
	self = [super init];

	if (self) {
		_preferences = [%c(HBTSPreferences) sharedInstance];
	}

	return self;
}

#pragma mark - Callbacks

- (NSNumber *)typingTypeWithSpecifier:(PSSpecifier *)specifier {
	return @(_preferences.typingType);
}

- (void)setTypingType:(NSNumber *)typingType specifier:(PSSpecifier *)specifier {
	_preferences.typingType = typingType.unsignedIntegerValue;
	notify_post("ws.hbang.typestatus/ReloadPrefs");
}

- (NSNumber *)readReceiptTypeWithSpecifier:(PSSpecifier *)specifier {
	return @(_preferences.readType);
}

- (void)setReadReceiptType:(NSNumber *)readType specifier:(PSSpecifier *)specifier {
	_preferences.readType = readType.unsignedIntegerValue;
	notify_post("ws.hbang.typestatus/ReloadPrefs");
}

- (void)testTyping {
	notify_post("ws.hbang.typestatus/TestTyping");
}

- (void)testReadReceipt {
	notify_post("ws.hbang.typestatus/TestRead");
}

@end
