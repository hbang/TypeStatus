#import "Global.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <IMDaemonCore/IMDMessageStore.h>
#import <IMFoundation/FZMessage.h>
#import <version.h>

#pragma mark - Communication with SpringBoard

void HBTSPostMessage(HBTSStatusBarType type, NSString *name, BOOL typing) {
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
		[[NSDistributedNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:HBTSSpringBoardReceivedMessageNotification object:nil userInfo:@{
			kHBTSMessageTypeKey: @(type),
			kHBTSMessageSenderKey: name ?: @"",
			kHBTSMessageIsTypingKey: @(typing)
		}]];
	});
}

#pragma mark - iMessage hooks

%group JonyIveIsCool

%hook IMDServiceSession

- (void)didReceiveMessage:(FZMessage *)message forChat:(id)chat style:(unsigned char)style {
	%orig;

	if (message.flags == FZMessageFlagsTypingBegan) {
		HBTSPostMessage(HBTSStatusBarTypeTyping, message.handle, YES);
	} else {
		HBTSPostMessage(HBTSStatusBarTypeTypingEnded, message.handle, NO);
	}
}

- (void)didReceiveMessageReadReceiptForMessageID:(NSString *)messageID date:(NSDate *)date completionBlock:(id)completion {
	%orig;

	FZMessage *message = [[%c(IMDMessageStore) sharedInstance] messageWithGUID:messageID];
	HBTSPostMessage(HBTSStatusBarTypeRead, message.handle, NO);
}

%end

%end

%group ForstallForTheWin

%hook IMDaemonListener

- (void)account:(id)account chat:(id)chat style:(unsigned char)style chatProperties:(id)properties messageReceived:(FZMessage *)message {
	%orig;

	if (message.flags == FZMessageFlagsTypingBegan) {
		HBTSPostMessage(HBTSStatusBarTypeTyping, message.handle, YES);
	} else {
		HBTSPostMessage(HBTSStatusBarTypeTypingEnded, message.handle, NO);
	}
}

%end

%hook FZMessage

// todo: make this less hacky

- (void)setTimeRead:(NSDate *)timeRead {
	%orig;

	if (!self.sender && [[NSDate date] timeIntervalSinceDate:self.timeRead] < 1) {
		HBTSPostMessage(HBTSStatusBarTypeRead, self.handle, NO);
	}
}

%end

%end

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

	if (IS_IOS_OR_NEWER(iOS_7_0)) {
		%init(JonyIveIsCool);
	} else {
		%init(ForstallForTheWin);
	}

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)HBTSTestTyping, CFSTR("ws.hbang.typestatus/TestTyping"), NULL, 0);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)HBTSTestRead, CFSTR("ws.hbang.typestatus/TestRead"), NULL, 0);
}
