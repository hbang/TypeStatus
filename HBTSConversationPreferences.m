#import "HBTSConversationPreferences.h"
#import <Cephei/HBPreferences.h>
#import <ChatKit/CKConversation.h>

@implementation HBTSConversationPreferences {
	HBPreferences *_preferences;
}

- (instancetype)init {
	self = [super init];

	if (self) {
		_preferences = [[HBPreferences alloc] initWithIdentifier:@"ws.hbang.typestatus.conversationprefs"];
	}

	return self;
}

- (NSString *)_keyForConversation:(CKConversation *)conversation type:(NSString *)type {
	if (!conversation._chatSupportsTypingIndicators || conversation.isGroupConversation) {
		return nil;
	}

	return [NSString stringWithFormat:@"%@-%@", conversation.uniqueIdentifier, type];
}

#pragma mark - Getters

- (BOOL)typingNotificationsEnabledForConversation:(CKConversation *)conversation {
	NSString *key = [self _keyForConversation:conversation type:@"Typing"];
	return key ? [_preferences boolForKey:key default:YES] : YES;
}

- (BOOL)readReceiptsEnabledForConversation:(CKConversation *)conversation {
	BOOL globallyEnabled = YES;

	NSString *key = [self _keyForConversation:conversation type:@"Read"];
	return key ? [_preferences boolForKey:key default:globallyEnabled] : globallyEnabled;
}

#pragma mark - Setters

- (void)setTypingNotificationsEnabled:(BOOL)enabled forConversation:(CKConversation *)conversation {

}

- (void)setReadReceiptsEnabled:(BOOL)enabled forConversation:(CKConversation *)conversation {

}


@end
