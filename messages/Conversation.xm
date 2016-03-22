#import "HBTSConversationPreferences.h"
#import <IMCore/IMChat.h>
#import <IMCore/IMHandle.h>

HBTSConversationPreferences *preferences = [[HBTSConversationPreferences alloc] init];

%hook CKConversation

- (void)setLocalUserIsTyping:(BOOL)isTyping {
	// if the local user is typing AND typing notifications are enabled, go ahead
	// and set it to YES. otherwise, they’re either not typing or have disabled
	// typing notifications.
	if ([preferences.class shouldEnable]) {
		%orig(isTyping && [preferences typingNotificationsEnabledForConversation:self]);
	} else {
		%orig;
	}
}

- (void)setLocalUserIsRecording:(BOOL)isRecording {
	// recording is pretty much the same thing as typing so we cover that too
	if ([preferences.class shouldEnable]) {
		%orig(isRecording && [preferences typingNotificationsEnabledForConversation:self]);
	} else {
		%orig;
	}
}

%end

// IMChatRegistry, we meet again

%hook IMChatRegistry

- (void)_chat_sendReadReceiptForAllMessages:(IMChat *)chat {
	// if read receipts are enabled, or we are disabled, we can call through to
	// the original method
	if ([preferences readReceiptsEnabledForHandle:chat.recipient.ID] || ![preferences.class shouldEnable]) {
		%orig;
	}
}

%end

%ctor {
	// only initialise these hooks if we’re allowed to
	if ([HBTSConversationPreferences shouldEnable]) {
		%init;
	}
}
