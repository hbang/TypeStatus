#import "HBTSStatusBarAlertServer.h"
#import "HBTSPreferences.h"
#import "HBTSStatusBarAlertController.h"
#import <Foundation/NSDistributedNotificationCenter.h>

@implementation HBTSStatusBarAlertServer

+ (NSString *)iconNameForType:(HBTSStatusBarType)type {
	NSString *name = nil;

	switch (type) {
		case HBTSStatusBarTypeTyping:
			name = @"TypeStatus";
			break;

		case HBTSStatusBarTypeRead:
			name = @"TypeStatusRead";
			break;

		case HBTSStatusBarTypeTypingEnded:
			break;
	}

	return name;
}

+ (NSString *)titleForType:(HBTSStatusBarType)type {
	static NSBundle *PrefsBundle;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		PrefsBundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatus.bundle"] retain];
	});

	NSString *text = @"";

	switch (type) {
		case HBTSStatusBarTypeTyping:
			text = [PrefsBundle localizedStringForKey:@"TYPING" value:nil table:@"Localizable"];
			break;

		case HBTSStatusBarTypeRead:
			text = [PrefsBundle localizedStringForKey:@"READ" value:nil table:@"Localizable"];
			break;

		case HBTSStatusBarTypeTypingEnded:
			break;
	}

	return text;
}

#pragma mark - Send

+ (void)sendAlertWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content {
	[self sendAlertWithIconName:iconName title:title content:content animatingInDirection:YES timeout:-1];
}

+ (void)sendAlertWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content animatingInDirection:(BOOL)direction timeout:(NSTimeInterval)timeout {
	if (timeout == -1) {
		timeout = ((HBTSPreferences *)[%c(HBTSPreferences) sharedInstance]).overlayDisplayDuration;
	}

	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSDistributedNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:HBTSClientSetStatusBarNotification object:nil userInfo:@{
			kHBTSMessageIconNameKey: iconName ?: @"",
			kHBTSMessageTitleKey: title ?: @"",
			kHBTSMessageContentKey: content ?: @"",
			kHBTSMessageDirectionKey: @(direction),

			kHBTSMessageTimeoutKey: @(timeout),
			kHBTSMessageSendDateKey: [NSDate date]
		}]];
	});
}

+ (void)sendAlertType:(HBTSStatusBarType)type sender:(NSString *)sender timeout:(NSTimeInterval)timeout {
	NSString *iconName = [self iconNameForType:type];
	NSString *title = [self titleForType:type];
	BOOL direction = type != HBTSStatusBarTypeTypingEnded;

	[self sendAlertWithIconName:iconName title:title content:sender animatingInDirection:direction timeout:timeout];
}

+ (void)hide {
	[self sendAlertWithIconName:nil title:nil content:nil animatingInDirection:NO timeout:0];
}

@end
