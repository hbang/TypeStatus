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

+ (NSString *)textForType:(HBTSStatusBarType)type sender:(NSString *)sender boldRange:(out NSRange *)boldRange {
	static NSBundle *PrefsBundle;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		PrefsBundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatus.bundle"] retain];
	});

	HBTSPreferences *preferences = [%c(HBTSPreferences) sharedInstance];

	switch (preferences.overlayFormat) {
		case HBTSStatusBarFormatNatural:
		{
			// natural string with name in bold
			NSString *format = @"";

			switch (type) {
				case HBTSStatusBarTypeTyping:
					format = [PrefsBundle localizedStringForKey:@"TYPING_NATURAL" value:nil table:@"Localizable"];
					break;

				case HBTSStatusBarTypeRead:
					format = [PrefsBundle localizedStringForKey:@"READ_NATURAL" value:nil table:@"Localizable"];
					break;

				case HBTSStatusBarTypeTypingEnded:
					break;
			}

			NSUInteger location = [format rangeOfString:@"%@"].location;

			// if the %@ wasn’t found, the string probably isn’t translated… this is
			// pretty bad so we should probably just return what we have so the error
			// is obvious
			if (location == NSNotFound) {
				*boldRange = NSMakeRange(0, 0);
				return format;
			}

			*boldRange = NSMakeRange(location, sender.length);

			return [NSString stringWithFormat:format, sender];
			break;
		}

		case HBTSStatusBarFormatTraditional:
		{
			// prefix Typing: or Read: in bold
			NSString *prefix = @"";

			switch (type) {
				case HBTSStatusBarTypeTyping:
					prefix = [PrefsBundle localizedStringForKey:@"TYPING" value:nil table:@"Localizable"];
					break;

				case HBTSStatusBarTypeRead:
					prefix = [PrefsBundle localizedStringForKey:@"READ" value:nil table:@"Localizable"];
					break;

				case HBTSStatusBarTypeTypingEnded:
					break;
			}

			*boldRange = NSMakeRange(0, prefix.length);

			return [NSString stringWithFormat:@"%@ %@", prefix, sender];
			break;
		}

		case HBTSStatusBarFormatNameOnly:
		{
			// just the sender name on its own
			*boldRange = NSMakeRange(0, sender.length);
			return sender;
			break;
		}
	}
}

#pragma mark - Send

+ (void)sendAlertWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content {
	[self sendAlertWithIconName:iconName title:title content:content animatingInDirection:YES timeout:-1];
}

+ (void)sendAlertWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content animatingInDirection:(BOOL)direction timeout:(NSTimeInterval)timeout {
	NSParameterAssert(title);

	if (timeout == -1) {
		timeout = ((HBTSPreferences *)[%c(HBTSPreferences) sharedInstance]).overlayDisplayDuration;
	}

	NSString *text = nil;

	if (content) {
		text = [NSString stringWithFormat:@"%@ %@", title, content];
	} else {
		text = title;
	}

	[self sendAlertWithIconName:iconName text:text boldRange:NSMakeRange(0, title.length) animatingInDirection:direction timeout:timeout];
}

+ (void)sendAlertWithIconName:(NSString *)iconName text:(NSString *)text boldRange:(NSRange)boldRange animatingInDirection:(BOOL)direction timeout:(NSTimeInterval)timeout {
	NSParameterAssert(text);

	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSDistributedNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:HBTSClientSetStatusBarNotification object:nil userInfo:@{
			kHBTSMessageIconNameKey: iconName ?: @"",
			kHBTSMessageContentKey: text,
			kHBTSMessageBoldRangeKey: @[ @(boldRange.location), @(boldRange.length) ],
			kHBTSMessageDirectionKey: @(direction),

			kHBTSMessageTimeoutKey: @(timeout),
			kHBTSMessageSendDateKey: [NSDate date]
		}]];
	});
}

+ (void)sendAlertType:(HBTSStatusBarType)type sender:(NSString *)sender timeout:(NSTimeInterval)timeout {
	NSString *iconName = [self iconNameForType:type];

	NSRange boldRange;
	NSString *text = [self textForType:type sender:sender boldRange:&boldRange];

	BOOL direction = type != HBTSStatusBarTypeTypingEnded;

	[self sendAlertWithIconName:iconName text:text boldRange:boldRange animatingInDirection:direction timeout:timeout];
}

+ (void)hide {
	[self sendAlertWithIconName:nil title:nil content:nil animatingInDirection:NO timeout:0];
}

@end
