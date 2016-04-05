#import "HBTSConversationPreferences.h"
#import <IMCore/IMChat.h>
#import <IMCore/IMHandle.h>
#import <IMDaemonCore/IMDServiceSession.h>

HBTSConversationPreferences *preferences;

@interface IMDAppleServiceSession : IMDServiceSession

@end

@interface MessageServiceSession : IMDAppleServiceSession

@end

@interface MessageServiceSession ()

- (BOOL)_typeStatus_readReceiptsEnabledForHandle:(NSString *)handle;

@end

%group Stuff
%hook MessageServiceSession

%new - (BOOL)_typeStatus_readReceiptsEnabledForHandle:(NSString *)handle {
	// if read receipts are enabled for this person, or we are completely
	// disabled, then read receipts should be sent
	return [preferences readReceiptsEnabledForHandle:handle] || ![preferences.class shouldEnable];
}

- (void)sendReadReceiptForMessage:(id)message toChatID:(NSString *)chatID identifier:(NSString *)identifier style:(unsigned char)style {
	if ([self _typeStatus_readReceiptsEnabledForHandle:identifier]) {
		%orig;
	}
}

- (void)sendPlayedReceiptForMessage:(id)message toChatID:(NSString *)chatID identifier:(NSString *)identifier style:(unsigned char)style {
	if ([self _typeStatus_readReceiptsEnabledForHandle:identifier]) {
		%orig;
	}
}

- (void)sendSavedReceiptForMessage:(id)message toChatID:(NSString *)chatID identifier:(NSString *)identifier style:(unsigned char)style {
	if ([self _typeStatus_readReceiptsEnabledForHandle:identifier]) {
		%orig;
	}
}

%end
%end

%hook IMDaemon

- (void)_loadServices {
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
