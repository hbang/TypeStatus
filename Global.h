#ifndef _TYPESTATUS_GLOBAL_H
#define _TYPESTATUS_GLOBAL_H

typedef NS_ENUM(NSUInteger, HBTSStatusBarType) {
	HBTSStatusBarTypeTyping,
	HBTSStatusBarTypeTypingEnded,
	HBTSStatusBarTypeRead
};

static NSTimeInterval const kHBTSTypingTimeout = 60.0;

/*
 old notification name is used here for compatibility with
 tweaks that listen into typestatus' notifications
*/

static NSString *const HBTSClientSetStatusBarNotification = @"HBTSClientSetStatusBar";
static NSString *const HBTSSpringBoardReceivedMessageNotification = @"HBTSSpringBoardReceivedMessageNotification";

static NSString *const kHBTSMessageTypeKey = @"Type";
static NSString *const kHBTSMessageSenderKey = @"Name";
static NSString *const kHBTSMessageIsTypingKey = @"Typing";
static NSString *const kHBTSMessageSendDateKey = @"Date";
#endif
