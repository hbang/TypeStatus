#import "HBTSStatusBarIconController.h"
#import "../api/HBTSIMessageProvider.h"
#import "../api/HBTSNotification+Private.h"
#import "../api/HBTSPreferences.h"
#import "../api/HBTSProviderController.h"
#import "HBTSContactHelper.h"
#import <Cephei/NSDictionary+HBAdditions.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>
#include <dlfcn.h>

@interface HBTSIMessageProvider ()

+ (NSString *)iconNameForType:(HBTSMessageType)type;

- (void)receivedRelayedNotification:(NSDictionary *)userInfo;
- (BOOL)_shouldShowAlertOfType:(HBTSMessageType)type;

@end

HBTSIMessageProvider *provider = nil;
HBTSPreferences *preferences;

#pragma mark - IPC

void ReceivedRelayedNotification(CFMachPortRef port, LMMessage *request, CFIndex size, void *info) {
	// check that we aren’t being given a message that’s too short
	if ((size_t)size < sizeof(LMMessage)) {
		HBLogError(@"received a bad message? size = %li", size);
		return;
	}

	// get the raw data sent
	const void *rawData = LMMessageGetData(request);
	size_t length = LMMessageGetDataLength(request);

	// translate to NSData, then NSDictionary
	CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8 *)rawData, length, kCFAllocatorNull);
	NSDictionary <NSString *, id> *userInfo = LMPropertyListForData((__bridge NSData *)data);

	// forward to the main controller
	if (!provider) {
		provider = (HBTSIMessageProvider *)[[HBTSProviderController sharedInstance] providerForAppIdentifier:@"com.apple.MobileSMS"];
	}

	[provider receivedRelayedNotification:userInfo];
}

#pragma mark - iMessage Provider

%hook HBTSIMessageProvider

%new + (NSString *)iconNameForType:(HBTSMessageType)type {
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

%new - (void)receivedRelayedNotification:(NSDictionary *)userInfo {
	HBTSMessageType type = (HBTSMessageType)((NSNumber *)userInfo[kHBTSMessageTypeKey]).intValue;
	NSString *sender = userInfo[kHBTSMessageSenderKey];
	BOOL isTyping = ((NSNumber *)userInfo[kHBTSMessageIsTypingKey]).boolValue;

	if (![self _shouldShowAlertOfType:type] || [HBTSContactHelper isHandleMuted:sender]) {
		return;
	}

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
	NSTimeInterval timeout = isTyping && preferences.useTypingTimeout ? kHBTSTypingTimeout : [HBTSPreferences sharedInstance].overlayDisplayDuration;

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

%new - (BOOL)_shouldShowAlertOfType:(HBTSMessageType)type {
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

%end

#pragma mark - Constructor

%ctor {
	dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);
	dlopen("/Library/MobileSubstrate/DynamicLibraries/TypeStatusClient.dylib", RTLD_LAZY);

	preferences = [HBTSPreferences sharedInstance];

	kern_return_t result = LMStartService(springboardService.serverName, CFRunLoopGetCurrent(), (CFMachPortCallBack)ReceivedRelayedNotification);

	if (result != KERN_SUCCESS) {
		HBLogError(@"failed to start service! result = %i", result);
	}
}
