#import "HBTSConversationPreferences.h"
#import <IMDaemonCore/IMDChat.h>
#import <IMDaemonCore/IMDChatRegistry.h>
#import <IMDaemonCore/IMDHandle.h>

@interface HBTSConversationPreferences ()

- (BOOL)_readReceiptsEnabled;

- (NSNumber *)readReceiptsEnabledForHandleAsNumber:(NSString *)handle;

@end

extern HBTSConversationPreferences *preferences;

void mirrorNativeReadReceiptPreferences() {
	// grab the chats, and the global state
	NSArray <IMDChat *> *chats = ((IMDChatRegistry *)[%c(IMDChatRegistry) sharedInstance]).chats;
	BOOL globalState = preferences._readReceiptsEnabled;

	// loop over the chats
	for (IMDChat *chat in chats) {
		// skip chats with more than one person
		if (chat.participants.count != 1) {
			continue;
		}
		
		// grab the handle
		NSString *handle = chat.participants[0].ID;

		// get the native read receipt value, as well as our own
		NSNumber *value = chat.properties[@"EnableReadReceiptForChat"];
		NSNumber *ourValue = [preferences readReceiptsEnabledForHandleAsNumber:handle];
		
		// if it’s been set at least once before and is different from the global state
		if (value && value.boolValue != globalState) {
			// mirror it over to our side
			[preferences setReadReceiptsEnabled:value.boolValue forHandle:handle];
		}
		
		// if we have a value, and the system doesn’t or it differs from ours
		if (ourValue && (!value || value.boolValue != ourValue.boolValue)) {
			// mirror it over to the other side
			[chat updateProperties:@{
				@"EnableReadReceiptForChat": ourValue,
				@"EnableReadReceiptForChatVersionID": @1
			}];
		}
	}
}

%hook IMDChatRegistry

- (void)loadChatsWithCompletionBlock:(void(^)())completion {
	// override the completion block so we can execute our mirror logic afterwards
	__block void (^oldCompletion)() = [completion copy];

	void (^newCompletion)() = ^{
		oldCompletion();
		mirrorNativeReadReceiptPreferences();
	};

	%orig(newCompletion);
}

%end

%ctor {
	// register a preference change block so we can execute another mirror
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)mirrorNativeReadReceiptPreferences, CFSTR("ws.hbang.typestatus/ReadReceiptSettingsChanged"), NULL, kNilOptions);
}
