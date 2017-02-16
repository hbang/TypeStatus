#import "HBTSConversationPreferences.h"
#import <version.h>

extern NSString *kFZDaemonPropertyEnableReadReceipts;

HBTSConversationPreferences *preferences;
BOOL hasValue = NO;
BOOL sendReceipt = NO;

%group Stuff
%hook MessageServiceSession

- (void)sendReadReceiptForMessage:(id)message toChatID:(NSString *)chatID identifier:(NSString *)identifier style:(unsigned char)style {
	// indicate to the hook below if receipts are blocked or not
	hasValue = YES;
	sendReceipt = [preferences readReceiptsEnabledForHandle:identifier];
	%orig;
	hasValue = NO;
}

- (void)sendPlayedReceiptForMessage:(id)message toChatID:(NSString *)chatID identifier:(NSString *)identifier style:(unsigned char)style {
	hasValue = YES;
	sendReceipt = [preferences readReceiptsEnabledForHandle:identifier];
	%orig;
	hasValue = NO;
}

- (void)sendSavedReceiptForMessage:(id)message toChatID:(NSString *)chatID identifier:(NSString *)identifier style:(unsigned char)style {
	hasValue = YES;
	sendReceipt = [preferences readReceiptsEnabledForHandle:identifier];
	%orig;
	hasValue = NO;
}

%end
%end

%hookf(Boolean, CFPreferencesGetAppBooleanValue, CFStringRef key, CFStringRef applicationID, Boolean *keyExistsAndHasValidFormat) {
	// if we’re being asked for the original unmodified value by HBTSConversationPreferences, give
	// it that
	if ([(__bridge NSString *)applicationID isEqualToString:@"com.apple.madrid"] && [(__bridge NSString *)key isEqualToString:@"ReadReceiptsEnabled-nohaxplz"]) {
		return %orig(CFSTR("ReadReceiptsEnabled"), applicationID, keyExistsAndHasValidFormat);
	}

	// if we are enabled, and com.apple.madrid’s ReadReceiptsEnabled key is being queried, and we
	// have something to use, override it. otherwise, return the original value as per usual
	if ([preferences.class shouldEnable] && [(__bridge NSString *)applicationID isEqualToString:@"com.apple.madrid"] && [(__bridge NSString *)key isEqualToString:@"ReadReceiptsEnabled"] && hasValue) {
		// if the pointer arg is non-null, set it
		if (keyExistsAndHasValidFormat != NULL) {
			*keyExistsAndHasValidFormat = YES;
		}

		// return our overridden value
		return sendReceipt;
	}

	return %orig;
}

%hook IMDaemon

- (void)_loadServices {
	// /System/Library/Messages/PlugIns/iMessage.imservice is lazy loaded by this method, and that’s
	// the bundle MessageServiceSession lives in. wait for it to be loaded and then allow the hooks
	// to be initialised
	%orig;
	%init(Stuff);
}

%end

%ctor {
	// only proceed if we’re allowed to
	if ([HBTSConversationPreferences isAvailable]) {
		preferences = [[HBTSConversationPreferences alloc] init];

		// only use these hooks on iOS <10
		if (!IS_IOS_OR_NEWER(iOS_10_0)) {
			%init;
		}
	}
}
