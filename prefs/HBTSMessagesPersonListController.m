#import "HBTSMessagesPersonListController.h"
#import "HBTSConversationPreferences.h"
#import "HBTSPersonTableCell.h"
#import <Preferences/PSSpecifier.h>

@implementation HBTSMessagesPersonListController {
	NSString *_handle;
	HBTSConversationPreferences *_preferences;
}

#pragma mark - HBListController

+ (NSString *)hb_specifierPlist {
	return @"MessagesPerson";
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	_preferences = [[HBTSConversationPreferences alloc] init];

	self.title = self.specifier.name;
	_handle = self.specifier.properties[kHBTSHandleKey];
}

#pragma mark - Callbacks

- (NSNumber *)typingNotificationsEnabledForSpecifier:(PSSpecifier *)specifier {
	return @([_preferences typingNotificationsEnabledForHandle:_handle]);
}

- (NSNumber *)readReceiptsEnabledForSpecifier:(PSSpecifier *)specifier {
	return @([_preferences readReceiptsEnabledForHandle:_handle]);
}

- (void)setTypingNotificationsEnabled:(NSNumber *)enabled forSpecifier:(PSSpecifier *)specifier {
	return [_preferences setTypingNotificationsEnabled:enabled.boolValue forHandle:_handle];
}

- (void)setReadReceiptsEnabled:(NSNumber *)enabled forSpecifier:(PSSpecifier *)specifier {
	return [_preferences setReadReceiptsEnabled:enabled.boolValue forHandle:_handle];
}

- (void)removePerson:(PSSpecifier *)specifier {
	[_preferences removeHandle:_handle];
	[self.navigationController popViewControllerAnimated:YES];
}

@end
