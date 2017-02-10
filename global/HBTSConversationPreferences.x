#import "HBTSConversationPreferences.h"
#import "HBTSPreferences.h"
#import <Cephei/HBPreferences.h>
#import <IMCore/IMChat.h>
#import <IMCore/IMHandle.h>
#import <IMDaemonCore/IMDChat.h>
#import <IMDaemonCore/IMDChatRegistry.h>
#import <version.h>

@interface IMChatRegistry : NSObject

+ (instancetype)sharedInstance;

- (NSArray <IMChat *> *)allExistingChats;

@end

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

		[self _mirrorNativeReadReceiptPreferences];
	}

	return self;
}

#pragma mark - State

- (BOOL)_isInIMAgent {
	NSString *bundle = [NSBundle mainBundle].bundleURL.lastPathComponent;
	return [bundle isEqualToString:@"imagent.app"];
}

- (BOOL)_readReceiptsEnabled {
	// use a special™ key when in imagent so we don’t override it
	CFStringRef key = self._isInIMAgent && !IS_IOS_OR_NEWER(iOS_10_0)
		? CFSTR("ReadReceiptsEnabled-nohaxplz")
		: CFSTR("ReadReceiptsEnabled");

	// the prefs bundle falls back to NO, so probably we should follow suit
	return CFPreferencesGetAppBooleanValue(key, CFSTR("com.apple.madrid"), nil);
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
	return key ? [_preferences boolForKey:key default:YES] : YES;
}

- (BOOL)readReceiptsEnabledForChat:(IMChat *)chat {
	NSString *key = [self _keyForChat:chat type:@"Read"];
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

- (void)setTypingNotificationsEnabled:(BOOL)enabled forChat:(IMChat *)chat {
	[_preferences setBool:enabled forKey:[self _keyForChat:chat type:@"Typing"]];
}

- (void)setReadReceiptsEnabled:(BOOL)enabled forChat:(IMChat *)chat {
	[_preferences setBool:enabled forKey:[self _keyForChat:chat type:@"Read"]];
}

- (void)setTypingNotificationsEnabled:(BOOL)enabled forHandle:(NSString *)handle {
	[_preferences setBool:enabled forKey:[self _keyForHandle:handle type:@"Typing"]];
}

- (void)setReadReceiptsEnabled:(BOOL)enabled forHandle:(NSString *)handle {
	[_preferences setBool:enabled forKey:[self _keyForHandle:handle type:@"Read"]];
}

#pragma mark - Add/Remove

- (void)addHandle:(NSString *)handle {
	[self setTypingNotificationsEnabled:YES forHandle:handle];
	[self setReadReceiptsEnabled:self._readReceiptsEnabled forHandle:handle];
}

- (void)removeHandle:(NSString *)handle {
	[_preferences removeObjectForKey:[self _keyForHandle:handle type:@"Typing"]];
	[_preferences removeObjectForKey:[self _keyForHandle:handle type:@"Read"]];
}

#pragma mark - Migrate

- (void)_mirrorNativeReadReceiptPreferences {
	// if we’re not in imagent, do nothing
	if (!self._isInIMAgent) {
		return;
	}

	// using %c(), so we don’t have to link IMCore where this class is used but this method isn’t
	NSArray <IMDChat *> *chats = ((IMDChatRegistry *)[%c(IMDChatRegistry) sharedInstance]).chats;
	BOOL globalState = self._readReceiptsEnabled;

	// loop over the chats
	for (IMChat *chat in chats) {
		// get the native read receipt value, as well as our own
		NSNumber *value = chat.properties[@"EnableReadReceiptForChat"];
		NSNumber *ourValue = _preferences[[self _keyForChat:chat type:@"Read"]];
		
		// if it’s been set at least once before and is different from the global state
		if (value && value.boolValue != globalState) {
			// mirror it over to our side
			[self setReadReceiptsEnabled:value.boolValue forChat:chat];
		} else if (!value) {
			// if the value is nil, but we have a value
			
			if (ourValue) {
				// mirror it over to the other side
				[chat updateProperties:@{
					@"EnableReadReceiptForChat": ourValue,
					@"EnableReadReceiptForChatVersionID": @1
				}];
			}
		}
	}
}

@end
