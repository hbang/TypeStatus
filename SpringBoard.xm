#include <substrate.h>
#import "Global.h"
#import <AddressBook/AddressBook.h>
#import <Cephei/HBPreferences.h>
#import <ChatKit/CKEntity.h>
#import <ChatKit/CKIMEntity.h>
#import <ChatKit/CKMadridEntity.h>
#import <ChatKit/CKMadridService.h>
#import <Foundation/NSDistributedNotificationCenter.h>
#import <IMCore/IMHandle.h>
#import <libstatusbar/LSStatusBarItem.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBUserAgent.h>
#import <version.h>

HBPreferences *preferences;
NSUInteger typingIndicators = 0;
LSStatusBarItem *typingStatusBarItem, *readStatusBarItem;

#pragma mark - Communication with clients

void HBTSPostMessage(HBTSStatusBarType type, NSString *name, BOOL typing) {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[[NSDistributedNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:HBTSClientSetStatusBarNotification object:nil userInfo:@{
			kHBTSMessageTypeKey: @(type),
			kHBTSMessageSenderKey: name ?: @"",
			kHBTSMessageIsTypingKey: @(typing),
			kHBTSMessageSendDateKey: [NSDate date],

			kHBTSPreferencesOverlayAnimationSlideKey: @([preferences boolForKey:kHBTSPreferencesOverlayAnimationSlideKey]),
			kHBTSPreferencesOverlayAnimationFadeKey: @([preferences boolForKey:kHBTSPreferencesOverlayAnimationFadeKey]),
			kHBTSPreferencesTypingTimeoutKey: @([preferences boolForKey:kHBTSPreferencesTypingTimeoutKey]),
			kHBTSPreferencesOverlayDurationKey: @([preferences doubleForKey:kHBTSPreferencesOverlayDurationKey])
		}]];
	});
}

#pragma mark - Hide while Messages is open

BOOL HBTSShouldHide(BOOL typing) {
	static NSArray *MessagesApps;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		MessagesApps = [@[ @"com.apple.MobileSMS", @"com.bitesms" ] retain];
	});

	if ([preferences boolForKey:typing ? kHBTSPreferencesTypingHideInMessagesKey : kHBTSPreferencesReadHideInMessagesKey]) {
		return !((SpringBoard *)[UIApplication sharedApplication]).isLocked && [MessagesApps containsObject:((SBUserAgent *)[%c(SBUserAgent) sharedUserAgent]).foregroundApplicationDisplayID];
	}

	return NO;
}

#pragma mark - Get contact name

NSString *HBTSNameForHandle(NSString *handle) {
	if ([handle isEqualToString:@"example@hbang.ws"]) {
		return @"John Appleseed";
	} else {
		NSString *name = handle;
		CKEntity *entity = nil;

		if (%c(CKMadridService)) { // 5.x
			CKMadridService *service = [[[%c(CKMadridService) alloc] init] autorelease];
			entity = [[service copyEntityForAddressString:handle] autorelease];
		} else if (%c(CKIMEntity)) { // 6.x
			entity = [[%c(CKIMEntity) copyEntityForAddressString:handle] autorelease];
		} else if (%c(CKEntity)) { // 7.x
			entity = [[%c(CKEntity) copyEntityForAddressString:handle] autorelease];
		}

		if ([entity.name isEqualToString:handle] // 5.x/6.x
			|| ([entity respondsToSelector:@selector(handle)] && !entity.handle.person)) { // 7.x
			return handle;
		}

		if ([entity respondsToSelector:@selector(handle)]) { // 7.0+
			name = entity.handle._displayNameWithAbbreviation ?: entity.name;
		} else { // 6.x
			name = entity.name;
		}

		return name;
	}
}

#pragma mark - Constructor

%ctor {
	dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);

	preferences = [[HBPreferences alloc] initWithIdentifier:kHBTSPreferencesDomain];
	[preferences registerDefaults:@{
		kHBTSPreferencesTypingStatusKey: @YES,
		kHBTSPreferencesTypingIconKey: @NO,
		kHBTSPreferencesTypingHideInMessagesKey: @YES,
		kHBTSPreferencesTypingTimeoutKey: @NO,

		kHBTSPreferencesReadStatusKey: @YES,
		kHBTSPreferencesReadIconKey: @NO,
		kHBTSPreferencesReadHideInMessagesKey: @YES,

		kHBTSPreferencesOverlayAnimationSlideKey: @YES,
		kHBTSPreferencesOverlayAnimationFadeKey: @YES,
		kHBTSPreferencesOverlayDurationKey: @5.f
	}];

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
				BOOL isTesting = !((NSNumber *)notification.userInfo[kHBTSMessageIsTypingKey]).boolValue;

				typingIndicators++;

				if (HBTSShouldHide(YES)) {
					break;
				}

				if ([preferences boolForKey:kHBTSPreferencesTypingIconKey]) {
					static dispatch_once_t onceToken;
					dispatch_once(&onceToken, ^{
						typingStatusBarItem = [[%c(LSStatusBarItem) alloc] initWithIdentifier:@"ws.hbang.typestatus.icon" alignment:StatusBarAlignmentRight];
						typingStatusBarItem.imageName = @"TypeStatus";
					});

					typingStatusBarItem.visible = YES;

					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(([preferences boolForKey:kHBTSPreferencesTypingTimeoutKey] || isTesting ? [preferences doubleForKey:kHBTSPreferencesOverlayDurationKey] : kHBTSTypingTimeout) * NSEC_PER_SEC)), dispatch_get_main_queue(), typingEnded);
				}

				if ([preferences boolForKey:kHBTSPreferencesTypingStatusKey]) {
					HBTSPostMessage(HBTSStatusBarTypeTyping, HBTSNameForHandle(notification.userInfo[kHBTSMessageSenderKey]), !isTesting);
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

				if ([preferences boolForKey:kHBTSPreferencesReadStatusKey]) {
					HBTSPostMessage(HBTSStatusBarTypeRead, HBTSNameForHandle(notification.userInfo[kHBTSMessageSenderKey]), NO);
				} else if ([preferences boolForKey:kHBTSPreferencesReadIconKey]) {
					static dispatch_once_t onceToken;
					dispatch_once(&onceToken, ^{
						readStatusBarItem = [[%c(LSStatusBarItem) alloc] initWithIdentifier:@"ws.hbang.typestatus.readicon" alignment:StatusBarAlignmentRight];
						readStatusBarItem.imageName = @"TypeStatusRead";
					});

					readStatusBarItem.visible = YES;

					dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)([preferences doubleForKey:kHBTSPreferencesOverlayDurationKey] * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
						readStatusBarItem.visible = NO;
					});
				}

				break;
			}
		}
	}];
}
