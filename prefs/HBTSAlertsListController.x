#import "HBTSAlertsListController.h"
#import "HBTSPreferences.h"
#import "HBTSStatusBarAlertController.h"
#import <Preferences/PSSpecifier.h>
#import <UIKit/UIScreen+Private.h>
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

#pragma mark - PSListController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self _configureAlertTypeSpecifiers];
}

- (void)reloadSpecifiers {
	[super reloadSpecifiers];
	[self _configureAlertTypeSpecifiers];
}

- (BOOL)_isHomeBarDevice {
	if (@available(iOS 11.0, *)) {
		return [UIScreen mainScreen]._sceneSafeAreaInsets.bottom > 0;
	}

	return NO;
}

- (void)_configureAlertTypeSpecifiers {
	if (self._isHomeBarDevice) {
		[self removeSpecifierID:@"TypingAlertTypeClassic"];
		[self removeSpecifierID:@"ReadAlertTypeClassic"];
		[self removeSpecifierID:@"SendingFileAlertTypeClassic"];
	} else {
		[self removeSpecifierID:@"TypingAlertTypeX"];
		[self removeSpecifierID:@"ReadAlertTypeX"];
		[self removeSpecifierID:@"SendingFileAlertTypeX"];
	}
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	// check that this is the cell we want to apply to
	if (specifier.cellType == PSSegmentCell && ([specifier.identifier hasSuffix:@"AlertTypeClassic"] || [specifier.identifier hasSuffix:@"AlertTypeX"])) {
		// get the value
		HBTSNotificationType type = (HBTSNotificationType)((NSNumber *)value).unsignedIntegerValue;

		// if it’s icon, and libstatusbar is not installed
		if (type == HBTSNotificationTypeIcon) {
			BOOL needsLibstatusbar = ![[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib"];

			if (needsLibstatusbar || self._isHomeBarDevice) {
				// flick it back to overlay
				value = @(HBTSNotificationTypeOverlay);
				[super setPreferenceValue:value specifier:specifier];

				// force the specifier to show the new value
				specifier.properties[PSValueKey] = value;
				[self reloadSpecifiers];
			}

			if (self._isHomeBarDevice) {
				// show not supported alert
				[self _showiPhoneXStatusBarIconAlert];
			} else if (needsLibstatusbar) {
				// show the install prompt
				[self _showLibstatusbarPrompt];
			}

			return;
		}
	}

	[super setPreferenceValue:value specifier:specifier];
}

- (void)_showiPhoneXStatusBarIconAlert {
	NSString *ok = NSLocalizedStringFromTableInBundle(@"OK", @"Localizable", [NSBundle bundleForClass:UIView.class], @"");
	UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Status Bar Icon is not yet available for iPhone X." message:nil delegate:nil cancelButtonTitle:ok otherButtonTitles:nil];
	[alertView show];
}

- (void)_showLibstatusbarPrompt {
	// this is friggin insanity
	NSString *package = IS_IOS_OR_NEWER(iOS_9_1) ? @"libstatus9" : @"libstatusbar";
	NSBundle *bundle = [NSBundle bundleForClass:self.class];
	NSString *title = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"INSTALL_LIBSTATUSBAR", @"Alerts", bundle, @""), package];
	NSString *body = [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"LIBSTATUSBAR_NOT_INSTALLED", @"Alerts", bundle, @""), package];
	NSString *yes = NSLocalizedStringFromTableInBundle(@"INSTALL", @"Alerts", bundle, @"");
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

		if (IS_IOS_OR_NEWER(iOS_9_1)) {
			url = [NSURL URLWithString:@"cydia://package/org.thebigboss.libstatus9"];
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
