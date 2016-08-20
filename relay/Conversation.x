#import "HBTSConversationPreferences.h"

extern NSString *kFZDaemonPropertyEnableReadReceipts;

HBTSConversationPreferences *preferences;

%group Stuff
%hook MessageServiceSession

- (void)sendReadReceiptForMessage:(id)message toChatID:(NSString *)chatID identifier:(NSString *)identifier style:(unsigned char)style {
	// if we are disabled, don’t do anything special. otherwise, %orig only if we
	// have been set to enabled
	if (![preferences.class shouldEnable] || [preferences readReceiptsEnabledForHandle:identifier]) {
		%orig;
	}
}

- (void)sendPlayedReceiptForMessage:(id)message toChatID:(NSString *)chatID identifier:(NSString *)identifier style:(unsigned char)style {
	if (![preferences.class shouldEnable] || [preferences readReceiptsEnabledForHandle:identifier]) {
		%orig;
	}
}

- (void)sendSavedReceiptForMessage:(id)message toChatID:(NSString *)chatID identifier:(NSString *)identifier style:(unsigned char)style {
	if (![preferences.class shouldEnable] || [preferences readReceiptsEnabledForHandle:identifier]) {
		%orig;
	}
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

%ctor {
	// only initialise these hooks if we’re allowed to
	if ([HBTSConversationPreferences shouldEnable]) {
		preferences = [[HBTSConversationPreferences alloc] init];
		%init;
	}
}
