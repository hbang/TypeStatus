#import <Foundation/NSDistributedNotificationCenter.h>
#import <IMDaemonCore/IMDMessageStore.h>
#import <IMDaemonCore/IMDServiceSession.h>
#import <IMFoundation/FZMessage.h>
#import <version.h>
#import <Foundation/NSXPCConnection.h>
#import <Foundation/NSXPCInterface.h>
#import <../daemon/HBTSDaemonManager.h>
#import "HBTSIMAgentRelayProtocol.h"

#pragma mark - Communication with SpringBoard

NSXPCConnection *connection = nil;

void HBTSPostMessage(HBTSStatusBarType type, NSString *name, BOOL typing) {
	if (!connection) {
		connection = [[NSXPCConnection alloc] initWithMachServiceName:kHBTSIMAgentMachServiceName options:kNilOptions];
		connection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HBTSIMAgentRelayProtocol)];
		[connection resume];
	}

	HBTSDaemonManager *daemonManager = [connection remoteObjectProxyWithErrorHandler:^(NSError *error) {
		if (error) {
			HBLogError(@"Could not send notification via XPC: %@", error);
			return;
		}
	}];

	[daemonManager sendNotificationWithStatusBarType:type senderName:name ?: @"" isTyping:typing];
}

#pragma mark - Typing/read notifications

@interface IMDServiceSession ()

- (void)_typeStatus_didReceiveMessage:(FZMessage *)message;

@end

%hook IMDServiceSession

%new - (void)_typeStatus_didReceiveMessage:(FZMessage *)message {
	if (message.isTypingMessage) {
		HBTSPostMessage(HBTSStatusBarTypeTyping, message.handle, YES);
	} else {
		HBTSPostMessage(HBTSStatusBarTypeTypingEnded, message.handle, NO);
	}
}

%group EddyCue
- (void)didReceiveMessage:(FZMessage *)message forChat:(id)chat style:(unsigned char)style account:(id)account {
	%orig;
	[self _typeStatus_didReceiveMessage:message];
}
%end

%group CraigFederighi
- (void)didReceiveMessage:(FZMessage *)message forChat:(id)chat style:(unsigned char)style {
	%orig;
	[self _typeStatus_didReceiveMessage:message];
}
%end

- (void)didReceiveMessageReadReceiptForMessageID:(NSString *)messageID date:(NSDate *)date completionBlock:(id)completion {
	%orig;
	HBTSPostMessage(HBTSStatusBarTypeRead, [[%c(IMDMessageStore) sharedInstance] messageWithGUID:messageID].handle, NO);
}

%end

#pragma mark - Block outgoing typing/read

/*
%hook IMDServiceSession

- (void)sendMessage:(FZMessage *)message toChat:(id)chat style:(unsigned char)style {
	%log;
	%orig;
}

- (void)sendReadReceiptForMessage:(FZMessage *)message toChatID:(id)chat identifier:(NSString *)identifier style:(unsigned char)style {
	%log;
	%orig;
}

%end
*/

#pragma mark - Test functions

void HBTSTestTyping() {
	HBTSPostMessage(HBTSStatusBarTypeTyping, @"example@hbang.ws", NO);
}

void HBTSTestRead() {
	HBTSPostMessage(HBTSStatusBarTypeRead, @"example@hbang.ws", NO);
}

#pragma mark - Constructor

%ctor {
	%init;

	if (IS_IOS_OR_NEWER(iOS_9_0)) {
		%init(EddyCue);
	} else {
		%init(CraigFederighi);
	}

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)HBTSTestTyping, CFSTR("ws.hbang.typestatus/TestTyping"), NULL, 0);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)HBTSTestRead, CFSTR("ws.hbang.typestatus/TestRead"), NULL, 0);
}
