#import "HBTSAlertsListController.h"
#import "HBTSPreferences.h"
#import <Preferences/PSSpecifier.h>
#import <version.h>
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

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	// check that this is the cell we want to apply to
	if (specifier.cellType == PSSegmentCell && [specifier.identifier hasSuffix:@"AlertType"]) {
		// get the value
		HBTSNotificationType type = (HBTSNotificationType)((NSNumber *)value).unsignedIntegerValue;
		
		// if it’s icon, and libstatusbar is not installed
		if (type == HBTSNotificationTypeIcon && ![[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib"]) {
			// flick it back to overlay
			value = @(HBTSNotificationTypeOverlay);
			[super setPreferenceValue:value specifier:specifier];

			// force the specifier to show the new value
			specifier.properties[PSValueKey] = value;
			[self reloadSpecifiers];

			// show the install prompt
			[self _showLibstatusbarPrompt];

			return;
		}
	}

	[super setPreferenceValue:value specifier:specifier];
}

- (void)_showLibstatusbarPrompt {
	// this is friggin insanity
	NSString *package = IS_IOS_OR_NEWER(iOS_9_0) ? @"libmoorecon" : @"libstatusbar";
	NSBundle *bundle = [NSBundle bundleForClass:self.class];
	NSString *title = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"INSTALL_LIBSTATUSBAR", @"Alerts", bundle, @""), package];
	NSString *body = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"LIBSTATUSBAR_NOT_INSTALLED", @"Alerts", bundle, @""), package];
	NSString *yes = NSLocalizedStringFromTableInBundle(@"INSTALL_NOW", @"Software Update", [NSBundle bundleForClass:PSListController.class], @"");
	NSString *no = NSLocalizedStringFromTableInBundle(@"Cancel", @"Localizable", [NSBundle bundleForClass:UIView.class], @"");

	// construct and show the alert view
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:body delegate:self cancelButtonTitle:no otherButtonTitles:yes, nil];
	[alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	// if this is the yes button
	if (buttonIndex == 1) {
		// determine the appropriate url for the iOS version
		NSURL *url;

		if (IS_IOS_OR_NEWER(iOS_9_0)) {
			url = [NSURL URLWithString:@"cydia://url/https://cydia.saurik.com/api/share#?source=http%3A%2F%2Ftateu.net%2Frepo%2F&package=libmoorecon"];
		} else {
			url = [NSURL URLWithString:@"cydia://package/libstatusbar"];
		}

		// open it
		[[UIApplication sharedApplication] openURL:url];
	}
}

#pragma mark - Callbacks

- (void)testTyping {
	notify_post("ws.hbang.typestatus/TestTyping");
}

- (void)testReadReceipt {
	notify_post("ws.hbang.typestatus/TestRead");
}

- (void)testSendingFile {
	notify_post("ws.hbang.typestatus/TestSendingFile");
}

@end
