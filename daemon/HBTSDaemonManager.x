#import "HBTSStatusBarIconController.h"
#import "HBTSStatusBarAlertServer.h"
#import "HBTSStatusBarAlertServer+Private.h"
#import "HBTSPreferences.h"
#import <ChatKit/CKEntity.h>
#import <ChatKit/CKDNDList.h>
#import <IMCore/IMHandle.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SpringBoard.h>
#include <dlfcn.h>
#import "HBTSDaemonManager.h"
#import <Foundation/NSXPCConnection.h>
#import <Foundation/NSXPCInterface.h>

typedef mach_port_t (*SBSSpringBoardServerPortType)();
typedef void (*SBFrontmostApplicationDisplayIdentifierType)(mach_port_t port, char *identifier);

SBSSpringBoardServerPortType SBSSpringBoardServerPort;
SBFrontmostApplicationDisplayIdentifierType SBFrontmostApplicationDisplayIdentifier;

@implementation HBTSDaemonManager {
	HBTSPreferences *_preferences;
}

- (instancetype)init {
	if (self = [super init]) {
		dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);

		void *sbs = dlopen("/System/Library/PrivateFrameworks/SpringBoardServices.framework/SpringBoardServices", RTLD_LAZY);

		SBSSpringBoardServerPort = (SBSSpringBoardServerPortType)dlsym(sbs, "SBSSpringBoardServerPort");
		SBFrontmostApplicationDisplayIdentifier = (SBFrontmostApplicationDisplayIdentifierType)dlsym(sbs, "SBFrontmostApplicationDisplayIdentifier");

		_preferences = [HBTSPreferences sharedInstance];

		NSXPCListener *listener = [NSXPCListener serviceListener];
		listener.delegate = self;
		[listener resume];
	}
	return self;
}

#pragma mark NSXPCListenerDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
	newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HBTSIMAgentRelayProtocol)];
	newConnection.exportedObject = self;
	[newConnection resume];
	return YES;
}

- (BOOL)shouldIgnoreNotification:(HBTSStatusBarType)type {
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
		char identifier[512];
		memset(identifier, 0, sizeof identifier);

		SBFrontmostApplicationDisplayIdentifier(SBSSpringBoardServerPort(), identifier);

		return strcmp(identifier, "com.apple.MobileSMS") == 0;
	}

	return NO;
}

- (NSString *)nameForHandle:(NSString *)handle {
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

- (void)sendNotificationWithStatusBarType:(HBTSStatusBarType)statusBarType senderName:(NSString *)senderName isTyping:(BOOL)typing {

	if ([self shouldIgnoreNotification:statusBarType]) {
		return;
	}

	if (%c(CKDNDList) && [(CKDNDList *)[%c(CKDNDList) sharedList] isMutedChatIdentifier:senderName]) {
		return;
	}

	HBTSNotificationType notificationType = HBTSNotificationTypeNone;

	switch (statusBarType) {
		case HBTSStatusBarTypeTyping:
		case HBTSStatusBarTypeTypingEnded:
			notificationType = _preferences.typingType;
			break;

		case HBTSStatusBarTypeRead:
			notificationType = _preferences.readType;
			break;
	}

	NSTimeInterval timeout = typing && _preferences.useTypingTimeout ? kHBTSTypingTimeout : _preferences.overlayDisplayDuration;

	switch (notificationType) {
		case HBTSNotificationTypeOverlay:
			[HBTSStatusBarAlertServer sendAlertType:statusBarType sender:[self nameForHandle:senderName] timeout:timeout];
			break;

		case HBTSNotificationTypeIcon:
			[HBTSStatusBarIconController showIconType:statusBarType timeout:timeout];
			break;

		case HBTSNotificationTypeNone:
			break;
	}
}

@end