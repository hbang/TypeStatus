#import "HBTSNotification+Private.h"
#import "HBTSStatusBarAlertServer.h"
#import "HBTSPreferences.h"
#import "HBTSStatusBarAlertController.h"
#import <Foundation/NSDistributedNotificationCenter.h>

@implementation HBTSStatusBarAlertServer

+ (NSString *)textForType:(HBTSMessageType)type sender:(NSString *)sender boldRange:(out NSRange *)boldRange {
	static NSBundle *PrefsBundle;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		PrefsBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatus.bundle"];
	});

	HBTSPreferences *preferences = [HBTSPreferences sharedInstance];

	switch (preferences.overlayFormat) {
		case HBTSStatusBarFormatNatural:
		{
			// natural string with name in bold
			NSString *format = @"";

			switch (type) {
				case HBTSMessageTypeTyping:
					format = [PrefsBundle localizedStringForKey:@"TYPING_NATURAL" value:nil table:@"Localizable"];
					break;

				case HBTSMessageTypeReadReceipt:
					format = [PrefsBundle localizedStringForKey:@"READ_NATURAL" value:nil table:@"Localizable"];
					break;

				case HBTSMessageTypeTypingEnded:
					break;

				case HBTSMessageTypeSendingFile:
					format = [PrefsBundle localizedStringForKey:@"SENDING_FILE_NATURAL" value:nil table:@"Localizable"];
					break;
			}

			NSUInteger location = [format rangeOfString:@"%@"].location;

			// if the %@ wasn’t found, the string probably isn’t translated… this is pretty bad so we
			// should probably just return what we have so the error is obvious
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

				case HBTSMessageTypeReadReceipt:
					prefix = [PrefsBundle localizedStringForKey:@"READ" value:nil table:@"Localizable"];
					break;

				case HBTSMessageTypeTypingEnded:
					break;

				case HBTSMessageTypeSendingFile:
					prefix = [PrefsBundle localizedStringForKey:@"SENDING_FILE" value:nil table:@"Localizable"];
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

+ (void)sendNotification:(HBTSNotification *)notification {
	HBLogDebug(@"showing notification %@", notification);

	// ensure no required arguments are missing
	NSParameterAssert(notification);

	// if the timeout is -1, replace it with the user's specified duration
	if (notification.timeout == -1) {
		notification.timeout = [HBTSPreferences sharedInstance].overlayDisplayDuration;
	}

	NSMutableDictionary *userInfo = [notification.dictionaryRepresentation mutableCopy];
	userInfo[kHBTSMessageDirectionKey] = @YES;

	// send the notification
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:HBTSClientSetStatusBarNotification object:nil userInfo:userInfo];
	});
}

+ (void)hide {
	HBLogDebug(@"hiding current notification");

	// a hide message is just sending nil values with the direction set to NO (hide)
	// send the notification
	dispatch_async(dispatch_get_main_queue(), ^{
		[[NSDistributedNotificationCenter defaultCenter] postNotificationName:HBTSClientSetStatusBarNotification object:nil userInfo:@{
			kHBTSMessageDirectionKey: @NO
		}];
	});
}

@end
