#import "HBTSConversationPreferences.h"
#import <IMCore/IMChat.h>
#import <IMCore/IMHandle.h>

HBTSConversationPreferences *preferences = [[HBTSConversationPreferences alloc] init];

%hook CKConversation

- (void)setLocalUserIsTyping:(BOOL)isTyping {
	// if the local user is typing AND typing notifications are enabled, go ahead
	// and set it to YES. otherwise, they’re either not typing or have disabled
	// typing notifications.
	%orig(isTyping && [preferences typingNotificationsEnabledForConversation:self]);
}

- (void)setLocalUserIsRecording:(BOOL)isRecording {
	// recording is pretty much the same thing as typing so we cover that too
	%orig(isRecording && [preferences typingNotificationsEnabledForConversation:self]);
}

%end

// IMChatRegistry, we meet again

%hook IMChatRegistry

- (void)_chat_sendReadReceiptForAllMessages:(IMChat *)chat {
	// if read receipts are enabled, we can call through to the original method
	if ([preferences readReceiptsEnabledForHandle:chat.recipient.ID]) {
		%orig;
	}
}

%end
