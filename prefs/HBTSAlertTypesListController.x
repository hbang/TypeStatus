#import "HBTSAlertTypesListController.h"
#import <Preferences/PSSpecifier.h>
#import "../Client/HBTSPreferences.h"
#include <notify.h>

@implementation HBTSAlertTypesListController {
	HBTSPreferences *_preferences;
}

+ (NSString *)hb_specifierPlist {
	return @"AlertTypes";
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
}

- (NSNumber *)readReceiptTypeWithSpecifier:(PSSpecifier *)specifier {
	return @(_preferences.readType);
}

- (void)setReadReceiptType:(NSNumber *)readType specifier:(PSSpecifier *)specifier {
	_preferences.readType = readType.unsignedIntegerValue;
}

- (void)testTyping {
	notify_post("ws.hbang.typestatus/TestTyping");
}

- (void)testReadReceipt {
	notify_post("ws.hbang.typestatus/TestRead");
}

@end
