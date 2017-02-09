#import "HBTSConversationPreferences.h"
#import <ChatKit/CKConversation.h>
#import <IMCore/IMChat.h>
#import <IMCore/IMHandle.h>
#import <version.h>

HBTSConversationPreferences *preferences;

%hook CKConversation

- (void)setLocalUserIsTyping:(BOOL)isTyping {
	// if the local user is typing AND typing notifications are enabled, go ahead and set it to YES.
	// otherwise, they’re either not typing or have disabled typing notifications
	if ([preferences.class shouldEnable]) {
		%orig(isTyping && [preferences typingNotificationsEnabledForChat:self.chat]);
	} else {
		%orig;
	}
}

- (void)setLocalUserIsRecording:(BOOL)isRecording {
	// recording is pretty much the same thing as typing so we cover that too
	if ([preferences.class shouldEnable]) {
		%orig(isRecording && [preferences typingNotificationsEnabledForChat:self.chat]);
	} else {
		%orig;
	}
}

%group PhilSchiller
- (void)setLocalUserIsComposing:(BOOL)isComposing typingIndicatorIcon:(id)icon {
	// “composing” presumably refers to all situations where the user is doing something that’s about
	// to be sent. for instance, drawing a digital touch thingy. so cover that as well
	if ([preferences.class shouldEnable]) {
		%orig(isComposing && [preferences typingNotificationsEnabledForChat:self.chat], icon);
	} else {
		%orig;
	}
}
%end

%end

%ctor {
	// only initialise these hooks if we’re allowed to
	if ([HBTSConversationPreferences isAvailable]) {
		preferences = [[HBTSConversationPreferences alloc] init];
		%init;

		if (IS_IOS_OR_NEWER(iOS_10_0)) {
			%init(PhilSchiller);
		}
	}
}
