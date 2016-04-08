#import "HBTSConversationPreferences.h"

extern NSString *kFZDaemonPropertyEnableReadReceipts;

HBTSConversationPreferences *preferences;
NSString *handle;

%group Stuff
%hook MessageServiceSession

- (void)sendReadReceiptForMessage:(id)message toChatID:(NSString *)chatID identifier:(NSString *)identifier style:(unsigned char)style {
	// copy the handle so we can use it in the hook below, then call orig
	handle = [identifier copy];
	%orig;
	[handle release];
	handle = nil;
}

- (void)sendPlayedReceiptForMessage:(id)message toChatID:(NSString *)chatID identifier:(NSString *)identifier style:(unsigned char)style {
	// copy the handle so we can use it in the hook below, then call orig
	handle = [identifier copy];
	%orig;
	[handle release];
	handle = nil;
}

- (void)sendSavedReceiptForMessage:(id)message toChatID:(NSString *)chatID identifier:(NSString *)identifier style:(unsigned char)style {
	// copy the handle so we can use it in the hook below, then call orig
	handle = [identifier copy];
	%orig;
	[handle release];
	handle = nil;
}

%end
%end

%hook IMDaemon

- (void)_loadServices {
	// /System/Library/Messages/PlugIns/iMessage.imservice is lazy loaded by this
	// method, and that’s the bundle MessageServiceSession lives in. wait for it
	// to be loaded and then allow the hooks to be initialised
	%orig;
	%init(Stuff);
}

%end

%hook IMDaemonListener

- (id)valueOfPersistentProperty:(NSString *)property {
	// if the property being accessed is the read receipts enabled property, and
	// we’re enabled, and we have the identifier, then return the value for that
	// particular person (or the fallback)
	if ([property isEqualToString:kFZDaemonPropertyEnableReadReceipts] && [preferences.class shouldEnable] && handle) {
		return @([preferences readReceiptsEnabledForHandle:handle]);
	}

	return %orig;
}

%end

%ctor {
	// only initialise these hooks if we’re allowed to
	if ([HBTSConversationPreferences shouldEnable]) {
		preferences = [[HBTSConversationPreferences alloc] init];
		%init;
	}
}
