#import "HBTSSpringBoardServer.h"
#import "HBTSContactHelper.h"
#import "HBTSPreferences.h"
#import "HBTSStatusBarAlertServer.h"
#import "HBTSStatusBarAlertServer+Private.h"
#import "HBTSStatusBarIconController.h"
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>

@implementation HBTSSpringBoardServer {
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
	HBTSStatusBarType type = (HBTSStatusBarType)((NSNumber *)userInfo[kHBTSMessageTypeKey]).intValue;
	NSString *sender = userInfo[kHBTSMessageSenderKey];
	BOOL isTyping = ((NSNumber *)userInfo[kHBTSMessageIsTypingKey]).boolValue;

	if (![self shouldShowAlertOfType:type] || [HBTSContactHelper isHandleMuted:sender]) {
		return;
	}

	HBTSNotificationType notificationType = HBTSNotificationTypeNone;

	switch (type) {
		case HBTSStatusBarTypeTyping:
		case HBTSStatusBarTypeTypingEnded:
			notificationType = _preferences.typingType;
			break;

		case HBTSStatusBarTypeRead:
			notificationType = _preferences.readType;
			break;
	}

	NSTimeInterval timeout = isTyping && _preferences.useTypingTimeout ? kHBTSTypingTimeout : _preferences.overlayDisplayDuration;

	switch (notificationType) {
		case HBTSNotificationTypeNone:
			break;

		case HBTSNotificationTypeOverlay:
			[%c(HBTSStatusBarAlertServer) sendAlertType:type sender:[HBTSContactHelper nameForHandle:sender useShortName:YES] timeout:timeout];
			break;

		case HBTSNotificationTypeIcon:
			[HBTSStatusBarIconController showIconType:type timeout:timeout];
			break;
	}
}

- (BOOL)shouldShowAlertOfType:(HBTSStatusBarType)type {
	BOOL hideInMessages = NO;

	switch (type) {
		case HBTSStatusBarTypeTyping:
		case HBTSStatusBarTypeTypingEnded:
			hideInMessages = _preferences.typingHideInMessages;
			break;

		case HBTSStatusBarTypeRead:
			hideInMessages = _preferences.readHideInMessages;
			break;
	}

	if (hideInMessages) {
		SpringBoard *app = (SpringBoard *)[UIApplication sharedApplication];

		// if the device is locked, or there is no frontmost app, or the frontmost
		// app is not messages, we can show it
		return app.isLocked || !app._accessibilityFrontMostApplication
			|| ![app._accessibilityFrontMostApplication.bundleIdentifier isEqualToString:@"com.apple.MobileSMS"];
	}

	return YES;
}

@end
