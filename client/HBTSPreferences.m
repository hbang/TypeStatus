#import "HBTSPreferences.h"
#import <Cephei/HBPreferences.h>

@implementation HBTSPreferences {
	HBPreferences *_preferences;

	BOOL _typingStatus;
	BOOL _typingIcon;
	BOOL _readStatus;
	BOOL _readIcon;
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

		[_preferences registerDefaults:@{
			@"TypingStatus": @YES,
			@"TypingIcon": @NO,

			@"ReadStatus": @YES,
			@"ReadIcon": @NO,

			@"OverlaySlide": @YES,
			@"OverlayFade": @NO,

			@"MessagesEnabled": @YES
		}];

		if (![_preferences objectForKey:@"OverlayAnimation"]) {
			HBTSStatusBarAnimation animation = HBTSStatusBarAnimationSlide;

			if ([_preferences boolForKey:@"OverlayFade"]) {
				animation = HBTSStatusBarAnimationFade;
			}

			[_preferences setInteger:animation forKey:@"OverlayAnimation"];
		}

		[_preferences registerBool:&_typingHideInMessages default:YES forKey:@"HideInMessages"];
		[_preferences registerBool:&_readHideInMessages default:YES forKey:@"HideReadInMessages"];

		[_preferences registerBool:&_useTypingTimeout default:NO forKey:@"TypingTimeout"];
		[_preferences registerDouble:&_overlayDisplayDuration default:5.0 forKey:@"OverlayDuration"];
		[_preferences registerInteger:(NSInteger *)&_overlayAnimation default:HBTSStatusBarAnimationSlide forKey:@"OverlayAnimation"];
		[_preferences registerInteger:(NSInteger *)&_overlayFormat default:HBTSStatusBarFormatNatural forKey:@"OverlayFormat"];

		[_preferences registerBool:&_ignoreDNDSenders default:YES forKey:@"IgnoreDNDSenders"];

		[_preferences registerBool:&_messagesEnabled default:YES forKey:@"MessagesEnabled"];
	}

	return self;
}

- (HBTSNotificationType)typingType {
	if ([_preferences boolForKey:@"TypingStatus"]) {
		return HBTSNotificationTypeOverlay;
	} else if ([_preferences boolForKey:@"TypingIcon"]) {
		return HBTSNotificationTypeIcon;
	} else {
		return HBTSNotificationTypeNone;
	}
}

- (void)setTypingType:(HBTSNotificationType)typingType {
	switch (typingType) {
		case HBTSNotificationTypeNone:
			[_preferences setBool:NO forKey:@"TypingStatus"];
			[_preferences setBool:NO forKey:@"TypingIcon"];
			break;

		case HBTSNotificationTypeOverlay:
			[_preferences setBool:YES forKey:@"TypingStatus"];
			[_preferences setBool:NO forKey:@"TypingIcon"];
			break;

		case HBTSNotificationTypeIcon:
			[_preferences setBool:NO forKey:@"TypingStatus"];
			[_preferences setBool:YES forKey:@"TypingIcon"];
			break;
	}
}

- (HBTSNotificationType)readType {
	if ([_preferences boolForKey:@"ReadStatus"]) {
		return HBTSNotificationTypeOverlay;
	} else if ([_preferences boolForKey:@"ReadIcon"]) {
		return HBTSNotificationTypeIcon;
	} else {
		return HBTSNotificationTypeNone;
	}
}

- (void)setReadType:(HBTSNotificationType)readType {
	switch (readType) {
		case HBTSNotificationTypeNone:
			[_preferences setBool:NO forKey:@"ReadStatus"];
			[_preferences setBool:NO forKey:@"ReadIcon"];
			break;

		case HBTSNotificationTypeOverlay:
			[_preferences setBool:YES forKey:@"ReadStatus"];
			[_preferences setBool:NO forKey:@"ReadIcon"];
			break;

		case HBTSNotificationTypeIcon:
			[_preferences setBool:NO forKey:@"ReadStatus"];
			[_preferences setBool:YES forKey:@"ReadIcon"];
			break;
	}
}

@end
