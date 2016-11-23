#import "HBTSConversationPreferences.h"

extern NSString *kFZDaemonPropertyEnableReadReceipts;

HBTSConversationPreferences *preferences;
BOOL sendReceipt = NO;

%group Stuff
%hook MessageServiceSession

- (void)sendReadReceiptForMessage:(id)message toChatID:(NSString *)chatID identifier:(NSString *)identifier style:(unsigned char)style {
	// indicate to the hook below if receipts are blocked or not
	sendReceipt = [preferences readReceiptsEnabledForHandle:identifier];
	%orig;
}

- (void)sendPlayedReceiptForMessage:(id)message toChatID:(NSString *)chatID identifier:(NSString *)identifier style:(unsigned char)style {
	sendReceipt = [preferences readReceiptsEnabledForHandle:identifier];
	%orig;
}

- (void)sendSavedReceiptForMessage:(id)message toChatID:(NSString *)chatID identifier:(NSString *)identifier style:(unsigned char)style {
	sendReceipt = [preferences readReceiptsEnabledForHandle:identifier];
	%orig;
}

%end
%end

%hookf(Boolean, CFPreferencesGetAppBooleanValue, CFStringRef key, CFStringRef applicationID, Boolean *keyExistsAndHasValidFormat) {
	// if we are enabled, and com.apple.madrid’s
	// ReadReceiptsEnabled key is being queried, override it. otherwise, return
	// the original value as per usual
	if ([preferences.class shouldEnable] && [(__bridge NSString *)applicationID isEqualToString:@"com.apple.madrid"] && [(__bridge NSString *)key isEqualToString:@"ReadReceiptsEnabled"]) {
		*keyExistsAndHasValidFormat = YES;
		// save value and set back to NO for safety
		BOOL temp = sendReceipt;
		sendReceipt = NO;
		return temp;
	}

	return %orig;
}

%hook IMDaemon

- (void)_loadServices {
	// /System/Library/Messages/PlugIns/iMessage.imservice is lazy loaded by this
	// method, and that’s the bundle MessageServiceSession lives in. wait for it
	// to be loaded and then allow the hooks to be initialised
	%orig;
	%init(Stuff);
}

%end

%ctor {
	// only initialise these hooks if we’re allowed to
	if ([HBTSConversationPreferences shouldEnable]) {
		preferences = [[HBTSConversationPreferences alloc] init];
		%init;
	}
}
