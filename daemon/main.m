#import "HBTSContactHelper.h"
#import "HBTSPreferences.h"
#import "HBTSStatusBarAlertServer.h"
#import "HBTSStatusBarAlertServer+Private.h"
#import "HBTSStatusBarIconController.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#include <dlfcn.h>

typedef mach_port_t (*SBSSpringBoardServerPortType)();
typedef void (*SBFrontmostApplicationDisplayIdentifierType)(mach_port_t port, char *identifier);
typedef void (*SBGetScreenLockStatusType)(mach_port_t port, bool *isLocked, bool *passcodeLocked);

SBSSpringBoardServerPortType SBSSpringBoardServerPort;
SBFrontmostApplicationDisplayIdentifierType SBFrontmostApplicationDisplayIdentifier;
SBGetScreenLockStatusType SBGetScreenLockStatus;

HBTSPreferences *preferences;

BOOL ShouldShowAlertOfType(HBTSStatusBarType type) {
	// get the appropriate setting
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

	return NO;
}

#pragma mark - Constructor

int main() {
	@autoreleasepool {
		// load libstatusbar manually because it’s stupidly designed
		dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);

		// get the relevant SpringBoardServices functions
		void *sbs = dlopen("/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices", RTLD_LAZY);
		SBSSpringBoardServerPort = (SBSSpringBoardServerPortType)dlsym(sbs, "SBSSpringBoardServerPort");
		SBFrontmostApplicationDisplayIdentifier = (SBFrontmostApplicationDisplayIdentifierType)dlsym(sbs, "SBFrontmostApplicationDisplayIdentifier");
		SBGetScreenLockStatus = (SBGetScreenLockStatusType)dlsym(sbs, "SBGetScreenLockStatus");

		// grab our preferences class
		preferences = [HBTSPreferences sharedInstance];

		// listen for the notification and call the block when it happens
		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:HBTSSpringBoardReceivedMessageNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			// get the data from the notification
			HBTSStatusBarType type = (HBTSStatusBarType)((NSNumber *)notification.userInfo[kHBTSMessageTypeKey]).intValue;
			NSString *sender = notification.userInfo[kHBTSMessageSenderKey];
			BOOL isTyping = ((NSNumber *)notification.userInfo[kHBTSMessageIsTypingKey]).boolValue;

			// confirm we can show this notification, return if not
			if (!ShouldShowAlertOfType(type) || [HBTSContactHelper isHandleMuted:sender]) {
				return;
			}

			// get the notification type from the preferences
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

			// calculate the timeout
			NSTimeInterval timeout = isTyping && preferences.useTypingTimeout ? kHBTSTypingTimeout : preferences.overlayDisplayDuration;

			// use the right method to display the notification
			switch (notificationType) {
				case HBTSNotificationTypeNone:
					break;

				case HBTSNotificationTypeOverlay:
					[HBTSStatusBarAlertServer sendAlertType:type sender:[HBTSContactHelper nameForHandle:sender useShortName:YES] timeout:timeout];
					break;

				case HBTSNotificationTypeIcon:
					[HBTSStatusBarIconController showIconType:type timeout:timeout];
					break;
			}
		}];

		// idle, waiting for something to happen
		[[NSRunLoop mainRunLoop] run];
	}
}
