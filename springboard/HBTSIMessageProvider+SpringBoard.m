#import "../api/HBTSIMessageProvider.h"
#import "../api/HBTSNotification+Private.h"
#import "../api/HBTSPreferences.h"
#import "../api/HBTSProviderController.h"
#import "HBTSContactHelper.h"
#import "HBTSStatusBarIconController.h"
#import <Cephei/NSDictionary+HBAdditions.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>

@implementation HBTSIMessageProvider (SpringBoard)

+ (NSString *)iconNameForType:(HBTSMessageType)type {
	// return the appropriate icon name
	NSString *name = nil;

	switch (type) {
		case HBTSMessageTypeTyping:
			name = @"TypeStatus";
			break;

		case HBTSMessageTypeReadReceipt:
			name = @"TypeStatusRead";
			break;

		case HBTSMessageTypeTypingEnded:
			break;

		case HBTSMessageTypeSendingFile:
			name = @"TypeStatus";
			break;
	}

	return name;
}

- (void)receivedRelayedNotification:(NSDictionary *)userInfo {
	HBTSMessageType type = (HBTSMessageType)((NSNumber *)userInfo[kHBTSMessageTypeKey]).intValue;
	NSString *sender = userInfo[kHBTSMessageSenderKey];
	BOOL isTyping = ((NSNumber *)userInfo[kHBTSMessageIsTypingKey]).boolValue;

	if (![self _shouldShowAlertOfType:type] || [HBTSContactHelper isHandleMuted:sender]) {
		return;
	}

	HBTSPreferences *preferences = [HBTSPreferences sharedInstance];
	HBTSNotificationType notificationType = HBTSNotificationTypeNone;

	switch (type) {
		case HBTSMessageTypeTyping:
		case HBTSMessageTypeTypingEnded:
			notificationType = preferences.typingAlertType;
			break;

		case HBTSMessageTypeReadReceipt:
			notificationType = preferences.readAlertType;
			break;

		case HBTSMessageTypeSendingFile:
			notificationType = preferences.sendingFileAlertType;
			break;
	}

	NSString *contactName = [HBTSContactHelper nameForHandle:sender useShortName:YES];
	NSString *iconName = [self.class iconNameForType:type];
	NSTimeInterval timeout = isTyping && preferences.useTypingTimeout ? kHBTSTypingTimeout : preferences.overlayDisplayDuration;

	switch (notificationType) {
		case HBTSNotificationTypeNone:
			break;

		case HBTSNotificationTypeOverlay:
		{
			HBTSNotification *notification = [[HBTSNotification alloc] initWithType:type sender:contactName iconName:iconName];
			notification.timeout = timeout;
			notification.actionURL = [NSURL URLWithString:[NSString stringWithFormat:@"sms://open?%@", @{
				@"address": sender ?: @""
			}.hb_queryString]];
			[self showNotification:notification];
			break;
		}

		case HBTSNotificationTypeIcon:
			switch (type) {
				case HBTSMessageTypeTyping:
				case HBTSMessageTypeReadReceipt:
				case HBTSMessageTypeSendingFile:
					[HBTSStatusBarIconController showIcon:iconName timeout:timeout];
					break;

				case HBTSMessageTypeTypingEnded:
					[HBTSStatusBarIconController hide];
					break;
			}

			break;
	}
}

- (BOOL)_shouldShowAlertOfType:(HBTSMessageType)type {
	HBTSPreferences *preferences = [HBTSPreferences sharedInstance];
	BOOL hideInMessages = NO;

	switch (type) {
		case HBTSMessageTypeTyping:
			hideInMessages = preferences.typingHideInMessages;
			break;

		case HBTSMessageTypeTypingEnded:
			return YES;
			break;

		case HBTSMessageTypeReadReceipt:
			hideInMessages = preferences.readHideInMessages;
			break;

		case HBTSMessageTypeSendingFile:
			hideInMessages = preferences.sendingFileHideInMessages;
			break;
	}

	if (hideInMessages) {
		SpringBoard *app = (SpringBoard *)[UIApplication sharedApplication];

		// if the device is locked, or there is no frontmost app, or the frontmost app is not messages,
		// we can show it
		return app.isLocked || !app._accessibilityFrontMostApplication
			|| ![app._accessibilityFrontMostApplication.bundleIdentifier isEqualToString:@"com.apple.MobileSMS"];
	}

	return YES;
}

@end
