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
		return app.isLocked || ![app._accessibilityFrontMostApplication.bundleIdentifier isEqualToString:@"com.apple.MobileSMS"];
	}

	return NO;
}

#pragma mark - Constructor

%ctor {
	dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);
	dlopen("/Library/MobileSubstrate/DynamicLibraries/TypeStatusClient.dylib", RTLD_LAZY);

	preferences = [%c(HBTSPreferences) sharedInstance];

	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:HBTSSpringBoardReceivedMessageNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		HBTSStatusBarType type = (HBTSStatusBarType)((NSNumber *)notification.userInfo[kHBTSMessageTypeKey]).intValue;
		NSString *sender = notification.userInfo[kHBTSMessageSenderKey];
		BOOL isTyping = ((NSNumber *)notification.userInfo[kHBTSMessageIsTypingKey]).boolValue;

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
				[HBTSStatusBarAlertServer sendAlertType:type sender:[HBTSContactHelper nameForHandle:sender useShortName:YES] timeout:timeout];
				break;

			case HBTSNotificationTypeIcon:
				[HBTSStatusBarIconController showIconType:type timeout:timeout];
				break;
		}
	}];
}
