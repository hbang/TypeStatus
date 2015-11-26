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

#pragma mark - External

- (BOOL)_readReceiptsEnabled {
	// the prefs bundle falls back to NO, so probably we should follow suit
	return CFPreferencesGetAppBooleanValue(CFSTR("ReadReceiptsEnabled"), CFSTR("com.apple.madrid"), nil);
}

#pragma mark - Keys

- (NSString *)_keyForConversation:(CKConversation *)conversation type:(NSString *)type {
	if (!conversation._chatSupportsTypingIndicators || conversation.isGroupConversation) {
		return nil;
	}

	return [NSString stringWithFormat:@"%@-%@", conversation.uniqueIdentifier, type];
}

- (NSString *)_keyForHandle:(NSString *)handle type:(NSString *)type {
	return [NSString stringWithFormat:@"%@-%@", handle, type];
}

#pragma mark - Getters

- (BOOL)typingNotificationsEnabledForConversation:(CKConversation *)conversation {
	NSString *key = [self _keyForConversation:conversation type:@"Typing"];
	return [_preferences boolForKey:key default:YES];
}

- (BOOL)readReceiptsEnabledForConversation:(CKConversation *)conversation {
	NSString *key = [self _keyForConversation:conversation type:@"Read"];
	return [_preferences boolForKey:key default:self._readReceiptsEnabled];
}

- (BOOL)typingNotificationsEnabledForHandle:(NSString *)handle {
	NSString *key = [self _keyForHandle:handle type:@"Typing"];
	return [_preferences boolForKey:key default:YES];
}

- (BOOL)readReceiptsEnabledForHandle:(NSString *)handle {
	NSString *key = [self _keyForHandle:handle type:@"Read"];
	return [_preferences boolForKey:key default:self._readReceiptsEnabled];
}

#pragma mark - Setters

- (void)setTypingNotificationsEnabled:(BOOL)enabled forConversation:(CKConversation *)conversation {
	[_preferences setBool:enabled forKey:[self _keyForConversation:conversation type:@"Typing"]];
}

- (void)setReadReceiptsEnabled:(BOOL)enabled forConversation:(CKConversation *)conversation {
	[_preferences setBool:enabled forKey:[self _keyForConversation:conversation type:@"Read"]];
}


@end
