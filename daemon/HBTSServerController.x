#import "HBTSServerController.h"
#import "HBTSContactHelper.h"
#import "HBTSPreferences.h"
#import "HBTSStatusBarAlertServer.h"
#import "HBTSStatusBarAlertServer+Private.h"
#import "HBTSStatusBarIconController.h"
#import <SpringBoardServices/SpringBoardServices.h>

@implementation HBTSServerController {
	HBTSPreferences *_preferences;
}

#pragma mark - NSObject

- (instancetype)init {
	self = [super init];

	if (self) {
		_preferences = [%c(HBTSPreferences) sharedInstance];
	}

	return self;
}

#pragma mark - Callbacks

- (void)receivedRelayedNotification:(NSDictionary *)userInfo {
	HBTSMessageType type = (HBTSMessageType)((NSNumber *)userInfo[kHBTSMessageTypeKey]).intValue;
	NSString *sender = userInfo[kHBTSMessageSenderKey];
	BOOL isTyping = ((NSNumber *)userInfo[kHBTSMessageIsTypingKey]).boolValue;

	if (![self shouldShowAlertOfType:type] || [HBTSContactHelper isHandleMuted:sender]) {
		return;
	}

	HBTSNotificationType notificationType = HBTSNotificationTypeNone;

	switch (type) {
		case HBTSMessageTypeTyping:
		case HBTSMessageTypeTypingEnded:
			notificationType = _preferences.typingAlertType;
			break;

		case HBTSMessageTypeReadReceipt:
			notificationType = _preferences.readAlertType;
			break;

		case HBTSMessageTypeSendingFile:
			notificationType = _preferences.sendingFileAlertType;
			break;
	}

	NSTimeInterval timeout = isTyping && _preferences.useTypingTimeout ? kHBTSTypingTimeout : _preferences.overlayDisplayDuration;

	switch (notificationType) {
		case HBTSNotificationTypeNone:
			break;

		case HBTSNotificationTypeOverlay:
			[HBTSStatusBarAlertServer sendMessagesAlertType:type sender:[HBTSContactHelper nameForHandle:sender useShortName:YES] timeout:timeout];
			break;

		case HBTSNotificationTypeIcon:
			[HBTSStatusBarIconController showIconType:type timeout:timeout];
			break;
	}
}

#pragma mark - Logic

- (BOOL)shouldShowAlertOfType:(HBTSMessageType)type {
	BOOL hideInMessages = NO;

	switch (type) {
		case HBTSMessageTypeTyping:
			hideInMessages = _preferences.typingHideInMessages;
			break;

		case HBTSMessageTypeTypingEnded:
			return YES;
			break;

		case HBTSMessageTypeReadReceipt:
			hideInMessages = _preferences.readHideInMessages;
			break;

		case HBTSMessageTypeSendingFile:
			hideInMessages = _preferences.sendingFileHideInMessages;
			break;
	}

	if (hideInMessages) {
		// if it’s messages, and the device isn’t locked, return NO
		return self._isDeviceLocked || ![self._frontmostAppIdentifier isEqualToString:@"com.apple.MobileSMS"];
	}

	return YES;
}

#pragma mark - SBS helpers

- (NSString *)_frontmostAppIdentifier {
	// get the SBS port
	mach_port_t port = SBSSpringBoardServerPort();

	// get the frontmost app id
	char identifier[512];
	memset(identifier, 0, sizeof identifier);
	SBFrontmostApplicationDisplayIdentifier(port, identifier);

	return [NSString stringWithUTF8String:identifier];
}

- (BOOL)_isDeviceLocked {
	// get the SBS port
	mach_port_t port = SBSSpringBoardServerPort();

	// get the screen lock status
	BOOL isLocked, passcodeLocked;
	SBGetScreenLockStatus(port, &isLocked, &passcodeLocked);

	return isLocked;
}

@end
