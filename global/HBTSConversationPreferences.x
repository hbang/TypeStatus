#import "HBTSConversationPreferences.h"
#import "HBTSPreferences.h"
#import <Cephei/HBPreferences.h>
#import <ChatKit/CKConversation.h>
#import <version.h>

@implementation HBTSConversationPreferences {
	HBPreferences *_preferences;
}

#pragma mark - Should be enabled

+ (BOOL)isAvailable {
	static BOOL hasConflict = NO;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		// we don't really want to do anything if someone else is already doing it
		hasConflict = [[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/SelectiveReading.dylib"];
	});

	// we also need iOS 9.0+
	return !hasConflict && IS_IOS_OR_NEWER(iOS_9_0);
}

+ (BOOL)shouldEnable {
	// if there's a conflict, return NO. otherwise, return whether the setting is enabled
	return [self isAvailable] && ((HBTSPreferences *)[%c(HBTSPreferences) sharedInstance]).messagesEnabled;
}

#pragma mark - NSObject

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
	return key ? [_preferences boolForKey:key default:YES] : YES;
}

- (BOOL)readReceiptsEnabledForConversation:(CKConversation *)conversation {
	NSString *key = [self _keyForConversation:conversation type:@"Read"];
	return key ? [_preferences boolForKey:key default:self._readReceiptsEnabled] : self._readReceiptsEnabled;
}

- (BOOL)typingNotificationsEnabledForHandle:(NSString *)handle {
	NSString *key = [self _keyForHandle:handle type:@"Typing"];
	return key ? [_preferences boolForKey:key default:YES] : YES;
}

- (BOOL)readReceiptsEnabledForHandle:(NSString *)handle {
	NSString *key = [self _keyForHandle:handle type:@"Read"];
	return key ? [_preferences boolForKey:key default:self._readReceiptsEnabled] : self._readReceiptsEnabled;
}

#pragma mark - Setters

- (void)setTypingNotificationsEnabled:(BOOL)enabled forConversation:(CKConversation *)conversation {
	[_preferences setBool:enabled forKey:[self _keyForConversation:conversation type:@"Typing"]];
}

- (void)setReadReceiptsEnabled:(BOOL)enabled forConversation:(CKConversation *)conversation {
	[_preferences setBool:enabled forKey:[self _keyForConversation:conversation type:@"Read"]];
}

@end
