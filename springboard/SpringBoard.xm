#import "HBTSContactHelper.h"
#import "HBTSPreferences.h"
#import "HBTSStatusBarAlertServer.h"
#import "HBTSStatusBarAlertServer+Private.h"
#import "HBTSStatusBarIconController.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBApplication.h>
#include <dlfcn.h>

HBTSPreferences *preferences;

#pragma mark - Should show alert

BOOL ShouldShowAlertOfType(HBTSStatusBarType type) {
	BOOL hideInMessages = NO;

	switch (type) {
		case HBTSStatusBarTypeTyping:
		case HBTSStatusBarTypeTypingEnded:
			hideInMessages = preferences.typingHideInMessages;
			break;

		case HBTSStatusBarTypeRead:
			hideInMessages = preferences.readHideInMessages;
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

#pragma mark - IPC

void ReceivedRelayedNotification(CFMachPortRef port, LMMessage *request, CFIndex size, void *info) {
	// check that we aren’t being given a message that’s too short
	if (size < sizeof(LMMessage)) {
		HBLogError(@"received a bad message? size = %li", size);
		return;
	}

	// get the raw data sent
	const void *rawData = LMMessageGetData(request);
	size_t length = LMMessageGetDataLength(request);

	// translate to NSData, then NSDictionary
	CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8 *)rawData, length, kCFAllocatorNull);
	NSDictionary <NSString *, id> *userInfo = LMPropertyListForData((__bridge NSData *)data);

	HBTSStatusBarType type = (HBTSStatusBarType)((NSNumber *)userInfo[kHBTSMessageTypeKey]).intValue;
	NSString *sender = userInfo[kHBTSMessageSenderKey];
	BOOL isTyping = ((NSNumber *)userInfo[kHBTSMessageIsTypingKey]).boolValue;

	if (!ShouldShowAlertOfType(type) || [HBTSContactHelper isHandleMuted:sender]) {
		return;
	}

	HBTSNotificationType notificationType = HBTSNotificationTypeNone;

	switch (type) {
		case HBTSStatusBarTypeTyping:
		case HBTSStatusBarTypeTypingEnded:
			notificationType = preferences.typingType;
			break;

		case HBTSStatusBarTypeRead:
			notificationType = preferences.readType;
			break;
	}

	NSTimeInterval timeout = isTyping && preferences.useTypingTimeout ? kHBTSTypingTimeout : preferences.overlayDisplayDuration;

	switch (notificationType) {
		case HBTSNotificationTypeOverlay:
			[%c(HBTSStatusBarAlertServer) sendAlertType:type sender:[HBTSContactHelper nameForHandle:sender useShortName:YES] timeout:timeout];
			break;

		case HBTSNotificationTypeIcon:
			[HBTSStatusBarIconController showIconType:type timeout:timeout];
			break;
	}
}

#pragma mark - Constructor

%ctor {
	dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);
	dlopen("/Library/MobileSubstrate/DynamicLibraries/TypeStatusClient.dylib", RTLD_LAZY);

	preferences = [%c(HBTSPreferences) sharedInstance];

	kern_return_t result = LMStartService((char *)"ws.hbang.typestatus.springboardserver", CFRunLoopGetCurrent(), (CFMachPortCallBack)ReceivedRelayedNotification);

	if (result) {
		HBLogError(@"failed to start service! result = %i", result);
	}
}
