#import "HBTSStatusBarAlertServer.h"
#import "HBTSPreferences.h"
#import "HBTSStatusBarAlertController.h"
#import <Foundation/NSDistributedNotificationCenter.h>

@implementation HBTSStatusBarAlertServer

+ (NSString *)iconNameForType:(HBTSMessageType)type {
	// return the appropriate icon name
	NSString *name = nil;

	switch (type) {
		case HBTSMessageTypeTyping:
			name = @"TypeStatus";
			break;

		case HBTSMessageTypeReadReceipt:
			name = @"TypeStatusRead";
			break;

		case HBTSMessageTypeTypingEnded:
			break;
	}

	return name;
}

+ (NSString *)textForType:(HBTSMessageType)type sender:(NSString *)sender boldRange:(out NSRange *)boldRange {
	static NSBundle *PrefsBundle;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		PrefsBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatus.bundle"];
	});

	HBTSPreferences *preferences = [%c(HBTSPreferences) sharedInstance];

	switch (preferences.overlayFormat) {
		case HBTSStatusBarFormatNatural:
		{
			// natural string with name in bold
			NSString *format = @"";

			switch (type) {
				case HBTSMessageTypeTyping:
					format = [PrefsBundle localizedStringForKey:@"TYPING_NATURAL" value:nil table:@"Localizable"];
					break;

				case HBTSMessageTypeRead:
					format = [PrefsBundle localizedStringForKey:@"READ_NATURAL" value:nil table:@"Localizable"];
					break;

				case HBTSMessageTypeTypingEnded:
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
				case HBTSMessageTypeTyping:
					prefix = [PrefsBundle localizedStringForKey:@"TYPING" value:nil table:@"Localizable"];
					break;

				case HBTSMessageTypeRead:
					prefix = [PrefsBundle localizedStringForKey:@"READ" value:nil table:@"Localizable"];
					break;

				case HBTSMessageTypeTypingEnded:
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
	// for backwards compat: pass through to the new method
	[self sendAlertWithIconName:iconName title:title content:content animatingInDirection:YES timeout:-1];
}

+ (void)sendAlertWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content animatingInDirection:(BOOL)direction timeout:(NSTimeInterval)timeout {
	// if this is a show command, ensure no arguments are missing
	if (direction) {
		NSParameterAssert(title);
	}

	// create a singular string with an NSRange for the title/bold part
	NSString *text = nil;

	if (content) {
		text = [NSString stringWithFormat:@"%@ %@", title, content];
	} else {
		text = title;
	}

	// pass through to the main sending method
	[self sendAlertWithIconName:iconName text:text boldRange:NSMakeRange(0, title.length) animatingInDirection:direction timeout:timeout];
}

+ (void)sendAlertWithIconName:(NSString *)iconName text:(NSString *)text boldRange:(NSRange)boldRange animatingInDirection:(BOOL)direction timeout:(NSTimeInterval)timeout {
	// if this is a show command, ensure no arguments are missing
	if (direction) {
		NSParameterAssert(text);
	}

	// if the timeout is -1, replace it with the user's specified duration
	if (timeout == -1) {
		timeout = ((HBTSPreferences *)[%c(HBTSPreferences) sharedInstance]).overlayDisplayDuration;
	}

	// send the notification
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSDistributedNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:HBTSClientSetStatusBarNotification object:nil userInfo:@{
			kHBTSMessageIconNameKey: iconName ?: @"",
			kHBTSMessageContentKey: text ?: @"",
			kHBTSMessageBoldRangeKey: @[ @(boldRange.location), @(boldRange.length) ],
			kHBTSMessageDirectionKey: @(direction),

			kHBTSMessageTimeoutKey: @(timeout),
			kHBTSMessageSendDateKey: [NSDate date]
		}]];
	});
}

+ (void)sendAlertType:(HBTSMessageType)type sender:(NSString *)sender timeout:(NSTimeInterval)timeout {
	// grab all data needed to turn a typestatus specific alert into a generic
	// alert, and then pass it through
	NSString *iconName = [self iconNameForType:type];

	NSRange boldRange;
	NSString *text = [self textForType:type sender:sender boldRange:&boldRange];

	BOOL direction = type != HBTSMessageTypeTypingEnded;

	[self sendAlertWithIconName:iconName text:text boldRange:boldRange animatingInDirection:direction timeout:timeout];
}

+ (void)hide {
	// a hide message is just sending nil values with the direction set to NO (hide)
	[self sendAlertWithIconName:nil title:nil content:nil animatingInDirection:NO timeout:0];
}

@end
