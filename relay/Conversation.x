#import "HBTSConversationPreferences.h"

extern NSString *kFZDaemonPropertyEnableReadReceipts;

HBTSConversationPreferences *preferences;
BOOL blockReceipt;

%group Stuff
%hook MessageServiceSession

- (void)sendReadReceiptForMessage:(id)message toChatID:(NSString *)chatID identifier:(NSString *)identifier style:(unsigned char)style {
	// if we are enabled, and receipts are disabled for this person, indicate to
	// the hook below that we’re blocking the receipt
	if ([preferences.class shouldEnable] && ![preferences readReceiptsEnabledForHandle:identifier]) {
		blockReceipt = YES;
	}

	%orig;
	blockReceipt = NO;
}

- (void)sendPlayedReceiptForMessage:(id)message toChatID:(NSString *)chatID identifier:(NSString *)identifier style:(unsigned char)style {
	if ([preferences.class shouldEnable] && ![preferences readReceiptsEnabledForHandle:identifier]) {
		blockReceipt = YES;
	}

	%orig;
	blockReceipt = NO;
}

- (void)sendSavedReceiptForMessage:(id)message toChatID:(NSString *)chatID identifier:(NSString *)identifier style:(unsigned char)style {
	if ([preferences.class shouldEnable] && ![preferences readReceiptsEnabledForHandle:identifier]) {
		blockReceipt = YES;
	}

	%orig;
	blockReceipt = NO;
}

%end
%end

%hookf(Boolean, CFPreferencesGetAppBooleanValue, CFStringRef key, CFStringRef applicationID, Boolean *keyExistsAndHasValidFormat) {
	// if we are meant to be blocking a receipt here, and com.apple.madrid’s
	// ReadReceiptsEnabled key is being queried, override it. otherwise, return
	// the original value as per usual
	if (blockReceipt && [(__bridge NSString *)applicationID isEqualToString:@"com.apple.madrid"] && [(__bridge NSString *)key isEqualToString:@"ReadReceiptsEnabled"]) {
		*keyExistsAndHasValidFormat = YES;
		return NO;
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
