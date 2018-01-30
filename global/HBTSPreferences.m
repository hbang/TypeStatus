#import "HBTSPreferences.h"
#import <Cephei/HBPreferences.h>

@implementation HBTSPreferences {
	HBPreferences *_preferences;
}

+ (instancetype)sharedInstance {
	static HBTSPreferences *sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (instancetype)init {
	self = [super init];

	if (self) {
		_preferences = [[HBPreferences alloc] initWithIdentifier:@"ws.hbang.typestatus"];

		[self _migrateIfNeeded];

		[_preferences registerInteger:(NSInteger *)&_typingAlertType default:HBTSNotificationTypeOverlay forKey:@"TypingAlertType"];
		[_preferences registerInteger:(NSInteger *)&_readAlertType default:HBTSNotificationTypeOverlay forKey:@"ReadAlertType"];
		[_preferences registerInteger:(NSInteger *)&_sendingFileAlertType default:HBTSNotificationTypeOverlay forKey:@"SendingFileAlertType"];

		[_preferences registerBool:&_typingHideInMessages default:YES forKey:@"HideInMessages"];
		[_preferences registerBool:&_readHideInMessages default:YES forKey:@"ReadHideInMessages"];
		[_preferences registerBool:&_sendingFileHideInMessages default:YES forKey:@"SendingFileHideInMessages"];

		[_preferences registerBool:&_useTypingTimeout default:NO forKey:@"TypingTimeout"];
		[_preferences registerDouble:&_overlayDisplayDuration default:5.0 forKey:@"OverlayDuration"];
		[_preferences registerBool:&_reduceMotion default:NO forKey:@"OverlayAnimation"];
		[_preferences registerInteger:(NSInteger *)&_overlayFormat default:HBTSStatusBarFormatNatural forKey:@"OverlayFormat"];

		[_preferences registerBool:&_ignoreDNDSenders default:YES forKey:@"IgnoreDNDSenders"];

		[_preferences registerBool:&_messagesEnabled default:YES forKey:@"MessagesEnabled"];
		[_preferences registerBool:&_messagesGlobalSendTyping default:YES forKey:@"MessagesGlobalSendTyping"];
	}

	return self;
}

- (void)_migrateIfNeeded {
	// upgrade old, ugly, boolean preferences to cleaner enums

	[_preferences registerDefaults:@{
		@"TypingStatus": @YES,
		@"TypingIcon": @NO,

		@"ReadStatus": @YES,
		@"ReadIcon": @NO,

		@"OverlaySlide": @YES,
		@"OverlayFade": @NO
	}];

	if (!_preferences[@"TypingAlertType"]) {
		HBTSNotificationType type = HBTSNotificationTypeNone;

		if ([_preferences boolForKey:@"TypingStatus"]) {
			type = HBTSNotificationTypeOverlay;
		} else if ([_preferences boolForKey:@"TypingIcon"]) {
			type = HBTSNotificationTypeIcon;
		}

		[_preferences setInteger:type forKey:@"TypingAlertType"];
	}

	if (!_preferences[@"ReadAlertType"]) {
		HBTSNotificationType type = HBTSNotificationTypeNone;

		if ([_preferences boolForKey:@"ReadStatus"]) {
			type = HBTSNotificationTypeOverlay;
		} else if ([_preferences boolForKey:@"ReadIcon"]) {
			type = HBTSNotificationTypeIcon;
		}

		[_preferences setInteger:type forKey:@"ReadAlertType"];
	}

	if (!_preferences[@"OverlayAnimation"]) {
		BOOL reduceMotion = [_preferences boolForKey:@"OverlayFade"];
		[_preferences setBool:reduceMotion forKey:@"OverlayAnimation"];
	}
}

@end
