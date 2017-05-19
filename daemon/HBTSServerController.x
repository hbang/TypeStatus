#import "HBTSServerController.h"
#import "HBTSContactHelper.h"
#import "HBTSPreferences.h"
#import "HBTSStatusBarAlertServer.h"
#import "HBTSStatusBarAlertServer+Private.h"
#import "HBTSStatusBarIconController.h"
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>

@implementation HBTSServerController {
	HBTSPreferences *_preferences;
}

- (instancetype)init {
	self = [super init];

	if (self) {
		_preferences = [%c(HBTSPreferences) sharedInstance];
	}

	return self;
}

- (void)receivedRelayedNotification:(NSDictionary *)userInfo {
	HBLogDebug(@"hi %@", userInfo);
	HBTSMessageType type = (HBTSMessageType)((NSNumber *)userInfo[kHBTSMessageTypeKey]).intValue;
	NSString *sender = userInfo[kHBTSMessageSenderKey];
	BOOL isTyping = ((NSNumber *)userInfo[kHBTSMessageIsTypingKey]).boolValue;

	HBLogDebug(@"asdsd");
	if (![self shouldShowAlertOfType:type] || [HBTSContactHelper isHandleMuted:sender]) {
		return;
	}
	HBLogDebug(@"asdsd");

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
	HBLogDebug(@"asdsd");

	NSTimeInterval timeout = isTyping && _preferences.useTypingTimeout ? kHBTSTypingTimeout : _preferences.overlayDisplayDuration;
	HBLogDebug(@"asdsd");

	switch (notificationType) {
		case HBTSNotificationTypeNone:
			break;

		case HBTSNotificationTypeOverlay:
			[%c(HBTSStatusBarAlertServer) sendMessagesAlertType:type sender:[HBTSContactHelper nameForHandle:sender useShortName:YES] timeout:timeout];
			break;

		case HBTSNotificationTypeIcon:
			[HBTSStatusBarIconController showIconType:type timeout:timeout];
			break;
	}
	HBLogDebug(@"asdsd");
}

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
		// get the SBS port
		mach_port_t port = SBSSpringBoardServerPort();

		// get the frontmost app id
		char identifier[512];
		memset(identifier, 0, sizeof identifier);
		SBFrontmostApplicationDisplayIdentifier(port, identifier);

		// get the screen lock status
		bool isLocked, passcodeLocked;
		SBGetScreenLockStatus(port, &isLocked, &passcodeLocked);

		// if it’s messages, and the device isn’t locked, return NO
		return isLocked || strcmp(identifier, "com.apple.MobileSMS") != 0;
	}

	return YES;
}

@end
