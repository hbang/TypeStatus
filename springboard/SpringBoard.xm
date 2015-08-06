#include <substrate.h>
#import "../client/HBTSPreferences.h"
#import <AddressBook/AddressBook.h>
#import <Cephei/HBPreferences.h>
#import <ChatKit/CKEntity.h>
#import <ChatKit/CKIMEntity.h>
#import <ChatKit/CKMadridEntity.h>
#import <ChatKit/CKMadridService.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <IMCore/IMHandle.h>
#import <libstatusbar/LSStatusBarItem.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SpringBoard.h>

HBTSPreferences *preferences;
NSUInteger typingIndicators = 0;
LSStatusBarItem *typingStatusBarItem, *readStatusBarItem;

#pragma mark - Communication with clients

void HBTSPostMessage(HBTSStatusBarType type, NSString *name, BOOL typing) {
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSDistributedNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:HBTSClientSetStatusBarNotification object:nil userInfo:@{
			kHBTSMessageTypeKey: @(type),
			kHBTSMessageSenderKey: name ?: @"",
			kHBTSMessageIsTypingKey: @(typing),
			kHBTSMessageSendDateKey: [NSDate date]
		}]];
	});
}

#pragma mark - Hide while Messages is open

BOOL HBTSShouldHide(BOOL typing) {
	if (typing ? preferences.typingHideInMessages : preferences.readHideInMessages) {
		SpringBoard *app = (SpringBoard *)[UIApplication sharedApplication];
		return !app.isLocked && [app._accessibilityFrontMostApplication.bundleIdentifier isEqualToString:@"com.apple.MobileSMS"];
	}

	return NO;
}

#pragma mark - Get contact name

NSString *HBTSNameForHandle(NSString *handle) {
	if ([handle isEqualToString:@"example@hbang.ws"]) {
		return @"John Appleseed";
	} else {
		CKEntity *entity = [[%c(CKEntity) copyEntityForAddressString:handle] autorelease];

		if (!entity || ([entity respondsToSelector:@selector(handle)] && !entity.handle.person)) {
			return handle;
		}

		return entity.handle._displayNameWithAbbreviation ?: entity.name;
	}
}

#pragma mark - Constructor

%ctor {
	dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);
	dlopen("/Library/MobileSubstrate/DynamicLibraries/TypeStatusClient.dylib", RTLD_LAZY);

	preferences = [%c(HBTSPreferences) sharedInstance];

	[[NSDistributedNotificationCenter defaultCenter] addObserverForName:HBTSSpringBoardReceivedMessageNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		static void (^typingEnded)() = ^{
			if (typingIndicators == 0) {
				return;
			}

			typingIndicators--;

			if (typingIndicators <= 0) {
				typingIndicators = 0;
			}

			if (typingIndicators <= 0) {
				if (typingStatusBarItem) {
					typingStatusBarItem.visible = NO;
				}

				HBTSPostMessage(HBTSStatusBarTypeTypingEnded, nil, NO);
			}
		};

		switch ((HBTSStatusBarType)((NSNumber *)notification.userInfo[kHBTSMessageTypeKey]).intValue) {
			case HBTSStatusBarTypeTyping:
			{
				BOOL isTyping = !((NSNumber *)notification.userInfo[kHBTSMessageIsTypingKey]).boolValue;

				typingIndicators++;

				if (HBTSShouldHide(YES)) {
					break;
				}

				if (preferences.typingType == HBTSNotificationTypeOverlay) {
					HBTSPostMessage(HBTSStatusBarTypeTyping, HBTSNameForHandle(notification.userInfo[kHBTSMessageSenderKey]), !isTyping);
				} else if (preferences.typingType == HBTSNotificationTypeIcon) {
					static dispatch_once_t onceToken;
					dispatch_once(&onceToken, ^{
						typingStatusBarItem = [[%c(LSStatusBarItem) alloc] initWithIdentifier:@"ws.hbang.typestatus.icon" alignment:StatusBarAlignmentRight];
						typingStatusBarItem.imageName = @"TypeStatus";
					});

					typingStatusBarItem.visible = YES;

					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)((preferences.useTypingTimeout || isTyping ? preferences.overlayDisplayDuration : kHBTSTypingTimeout) * NSEC_PER_SEC)), dispatch_get_main_queue(), typingEnded);
				}

				break;
			}

			case HBTSStatusBarTypeTypingEnded:
				typingEnded();
				break;

			case HBTSStatusBarTypeRead:
			{
				if (HBTSShouldHide(NO)) {
					break;
				}

				if (preferences.readType == HBTSNotificationTypeOverlay) {
					HBTSPostMessage(HBTSStatusBarTypeRead, HBTSNameForHandle(notification.userInfo[kHBTSMessageSenderKey]), NO);
				} else if (preferences.readType == HBTSNotificationTypeIcon) {
					static dispatch_once_t onceToken;
					dispatch_once(&onceToken, ^{
						readStatusBarItem = [[%c(LSStatusBarItem) alloc] initWithIdentifier:@"ws.hbang.typestatus.readicon" alignment:StatusBarAlignmentRight];
						readStatusBarItem.imageName = @"TypeStatusRead";
					});

					readStatusBarItem.visible = YES;

					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(preferences.overlayDisplayDuration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
						readStatusBarItem.visible = NO;
					});
				}

				break;
			}
		}
	}];
}
