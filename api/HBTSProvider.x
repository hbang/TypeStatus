#import "HBTSProvider.h"
#import "HBTSPreferences.h"
#import "HBTSProviderController.h"
#import "HBTSStatusBarAlertServer.h"

@implementation HBTSProvider

#pragma mark - NSObject

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; name = %@; appIdentifier = %@; prefs = %@ - %@>", self.class, self, _name, _appIdentifier, _preferencesBundle, _preferencesClass];
}

#pragma mark - State

- (BOOL)isEnabled {
	HBTSPreferences *preferences = [%c(HBTSPreferences) sharedInstance];

	if (self.preferencesBundle) {
		// the provider manages its own preferences. return YES
		return YES;
	} else {
		// ask the preferences if we're enabled
		return [preferences isProviderEnabled:self.appIdentifier];
	}
}

#pragma mark - Messaging methods

- (void)showNotification:(HBTSNotification *)notification {
	// don't bother doing anything if this provider is disabled
	if (!self.isEnabled) {
		return;
	}

	// override the section id with the app id if it’s nil
	if (!notification.sourceBundleID) {
		notification.sourceBundleID = _appIdentifier;
	}

	// post the notification
	[HBTSStatusBarAlertServer sendNotification:notification];
}

- (void)hideNotification {
	// don't bother doing anything if this provider is disabled
	if (!self.isEnabled) {
		return;
	}

	// post the notification
	[HBTSStatusBarAlertServer hide];
}

@end
