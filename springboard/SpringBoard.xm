#import "HBTSStatusBarIconController.h"
#import "../client/HBTSPreferences.h"
#import <Cephei/HBPreferences.h>
#import <ChatKit/CKEntity.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <IMCore/IMHandle.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SpringBoard.h>
#include <dlfcn.h>

HBTSPreferences *preferences;

#pragma mark - Communication with clients

void HBTSPostMessage(HBTSStatusBarType type, NSString *name, NSTimeInterval timeout) {
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSDistributedNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:HBTSClientSetStatusBarNotification object:nil userInfo:@{
			kHBTSMessageTypeKey: @(type),
			kHBTSMessageSenderKey: name ?: @"",
			kHBTSMessageDurationKey: @(timeout),
			kHBTSMessageSendDateKey: [NSDate date]
		}]];
	});
}

#pragma mark - Hide while Messages is open

BOOL HBTSShouldHide(HBTSStatusBarType type) {
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
		return !app.isLocked && [app._accessibilityFrontMostApplication.bundleIdentifier isEqualToString:@"com.apple.MobileSMS"];
	}

	return NO;
}

#pragma mark - Get contact name

NSString *HBTSNameForHandle(NSString *handle) {
	if ([handle isEqualToString:@"example@hbang.ws"]) {
		return @"Johnny Appleseed";
	} else {
		CKEntity *entity = [[%c(CKEntity) copyEntityForAddressString:handle] autorelease];

		if (!entity || ([entity respondsToSelector:@selector(handle)] && !entity.handle.person)) {
			return handle;
		}

		return entity.handle._displayNameWithAbbreviation ?: entity.name;
	}
}

#pragma mark - Show/hide

void HBTSShowOverlay(HBTSStatusBarType type, NSString *handle, NSTimeInterval duration) {
	static NSBundle *PrefsBundle;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		PrefsBundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatus.bundle"] retain];
	});

	NSString *name = HBTSNameForHandle(handle);

	if (UIAccessibilityIsVoiceOverRunning()) {
		NSString *typeString = @"";

		switch (type) {
			case HBTSStatusBarTypeTyping:
				typeString = [PrefsBundle localizedStringForKey:@"Typing:" value:@"Typing:" table:@"Root"];
				break;

			case HBTSStatusBarTypeRead:
				typeString = [PrefsBundle localizedStringForKey:@"Read:" value:@"Read:" table:@"Root"];
				break;

			case HBTSStatusBarTypeTypingEnded:
				break;
		}

		UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"%@ %@", typeString, name]);
	}

	HBTSPostMessage(type, name, duration);
}

void HBTSShowAlert(HBTSStatusBarType type, NSString *sender, BOOL isTyping) {
	if (HBTSShouldHide(type)) {
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

	NSTimeInterval duration = isTyping && preferences.useTypingTimeout ? kHBTSTypingTimeout : preferences.overlayDisplayDuration;

	switch (notificationType) {
		case HBTSNotificationTypeOverlay:
			HBTSShowOverlay(type, sender, duration);
			break;

		case HBTSNotificationTypeIcon:
			[HBTSStatusBarIconController showIconType:type timeout:duration];
			break;
	}
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

		HBTSShowAlert(type, sender, isTyping);
	}];
}
