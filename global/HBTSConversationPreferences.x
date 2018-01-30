#import "HBTSConversationPreferences.h"
#import "HBTSPreferences.h"
#import <IMCore/IMChat.h>
#import <IMCore/IMHandle.h>
#import <version.h>
#include <notify.h>

@implementation HBTSConversationPreferences {
	HBPreferences *_preferences;
}

#pragma mark - Should be enabled

+ (BOOL)isAvailable {
	static BOOL isAvailable = NO;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		// we need to be on iOS 9.0+
		isAvailable = IS_IOS_OR_NEWER(iOS_9_0) &&
			// we don't really want to do anything if someone else is already doing it
			![[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/SelectiveReading.dylib"] &&
			// Remote Messages also likes to be annoying by calling its daemon com.apple.MobileSMS. make
			// sure we don’t touch it
			![[NSBundle mainBundle].executablePath isEqualToString:@"/Library/Application Support/RemoteMessages/RemoteMessages"];
	});

	return isAvailable;
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

#pragma mark - State

- (BOOL)_isInIMAgent {
	NSString *bundle = [NSBundle mainBundle].bundleURL.lastPathComponent;
	return [bundle isEqualToString:@"imagent.app"];
}

- (BOOL)_typingNotificationsEnabled {
	return ((HBTSPreferences *)[%c(HBTSPreferences) sharedInstance]).messagesGlobalSendTyping;
}

- (BOOL)_readReceiptsEnabled {
	// use a special™ key when in imagent so we don’t override it
	CFStringRef key = self._isInIMAgent && !IS_IOS_OR_NEWER(iOS_10_0)
		? CFSTR("ReadReceiptsEnabled-nohaxplz")
		: CFSTR("ReadReceiptsEnabled");

	// the prefs bundle falls back to NO, so probably we should follow suit
	return CFPreferencesGetAppBooleanValue(key, CFSTR("com.apple.madrid"), nil);
}

- (void)registerPreferenceChangeBlock:(HBPreferencesChangeCallback)callback {
	[_preferences registerPreferenceChangeBlock:callback];
}

- (void)_postReadReceiptNotification {
	// if we do this in imagent, the callback for this notification can cause an infinite loop, so
	// don’t post it in that case
	if (!self._isInIMAgent) {
		notify_post("ws.hbang.typestatus/ReadReceiptSettingsChanged");
	}
}

#pragma mark - Keys

- (NSString *)_keyForChat:(IMChat *)chat type:(NSString *)type {
	return [NSString stringWithFormat:@"%@-%@", chat.recipient.ID, type];
}

- (NSString *)_keyForHandle:(NSString *)handle type:(NSString *)type {
	return [NSString stringWithFormat:@"%@-%@", handle, type];
}

#pragma mark - Getters

- (NSDictionary *)dictionaryRepresentation {
	return _preferences.dictionaryRepresentation;
}

- (BOOL)typingNotificationsEnabledForChat:(IMChat *)chat {
	NSString *key = [self _keyForChat:chat type:@"Typing"];
	return key ? [_preferences boolForKey:key default:self._typingNotificationsEnabled] : self._typingNotificationsEnabled;
}

- (BOOL)readReceiptsEnabledForChat:(IMChat *)chat {
	NSString *key = [self _keyForChat:chat type:@"Read"];
	return key ? [_preferences boolForKey:key default:self._readReceiptsEnabled] : self._readReceiptsEnabled;
}

- (BOOL)typingNotificationsEnabledForHandle:(NSString *)handle {
	NSString *key = [self _keyForHandle:handle type:@"Typing"];
	return key ? [_preferences boolForKey:key default:self._typingNotificationsEnabled] : self._typingNotificationsEnabled;
}

- (BOOL)readReceiptsEnabledForHandle:(NSString *)handle {
	NSString *key = [self _keyForHandle:handle type:@"Read"];
	return key ? [_preferences boolForKey:key default:self._readReceiptsEnabled] : self._readReceiptsEnabled;
}

- (NSNumber *)readReceiptsEnabledForHandleAsNumber:(NSString *)handle {
	NSString *key = [self _keyForHandle:handle type:@"Read"];
	return key ? [_preferences objectForKey:key] : nil;
}

#pragma mark - Setters

- (void)setTypingNotificationsEnabled:(BOOL)enabled forChat:(IMChat *)chat {
	[_preferences setBool:enabled forKey:[self _keyForChat:chat type:@"Typing"]];
}

- (void)setReadReceiptsEnabled:(BOOL)enabled forChat:(IMChat *)chat {
	[_preferences setBool:enabled forKey:[self _keyForChat:chat type:@"Read"]];
	[self _postReadReceiptNotification];
}

- (void)setTypingNotificationsEnabled:(BOOL)enabled forHandle:(NSString *)handle {
	[_preferences setBool:enabled forKey:[self _keyForHandle:handle type:@"Typing"]];
}

- (void)setReadReceiptsEnabled:(BOOL)enabled forHandle:(NSString *)handle {
	[_preferences setBool:enabled forKey:[self _keyForHandle:handle type:@"Read"]];
	[self _postReadReceiptNotification];
}

#pragma mark - Add/Remove

- (void)addHandle:(NSString *)handle {
	[self setTypingNotificationsEnabled:self._typingNotificationsEnabled forHandle:handle];
	[self setReadReceiptsEnabled:self._readReceiptsEnabled forHandle:handle];
}

- (void)removeHandle:(NSString *)handle {
	[_preferences removeObjectForKey:[self _keyForHandle:handle type:@"Typing"]];
	[_preferences removeObjectForKey:[self _keyForHandle:handle type:@"Read"]];
}

@end
