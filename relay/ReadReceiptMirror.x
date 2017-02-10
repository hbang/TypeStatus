#import "HBTSConversationPreferences.h"
#import <IMDaemonCore/IMDChat.h>
#import <IMDaemonCore/IMDChatRegistry.h>
#import <IMDaemonCore/IMDHandle.h>

@interface HBTSConversationPreferences ()

- (BOOL)_readReceiptsEnabled;

@end

extern HBTSConversationPreferences *preferences;

// ugly workaround to avoid infinite loops
BOOL updating = YES;

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
		BOOL ourValue = [preferences readReceiptsEnabledForHandle:handle];
		
		// if it’s been set at least once before and is different from the global state
		if (value && value.boolValue != globalState) {
			// mirror it over to our side
			updating = YES;
			[preferences setReadReceiptsEnabled:value.boolValue forHandle:handle];
		} else if (!value && ourValue != globalState) {
			// if the value is nil, but we have a value that is different from the global state
			// mirror it over to the other side
			[chat updateProperties:@{
				@"EnableReadReceiptForChat": @(ourValue),
				@"EnableReadReceiptForChatVersionID": @1
			}];
		}
	}
}

%hook IMDChatRegistry

- (void)loadChatsWithCompletionBlock:(void(^)())completion {
	// override the completion block so we can execute our mirror logic immediately
	void (^newCompletion)() = ^{
		completion();
		mirrorNativeReadReceiptPreferences();
	};

	%orig(newCompletion);
}

%end

%ctor {
	[preferences registerPreferenceChangeBlock:^{
		if (updating) {
			updating = NO;
		} else {
			mirrorNativeReadReceiptPreferences();
		}
	}];
}
