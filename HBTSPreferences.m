#import "HBTSPreferences.h"
#import <Cephei/HBPreferences.h>

static NSString *const kHBTSPreferencesDomain = @"ws.hbang.typestatus";

static NSString *const kHBTSPreferencesTypingStatusKey = @"TypingStatus";
static NSString *const kHBTSPreferencesTypingIconKey = @"TypingIcon";
static NSString *const kHBTSPreferencesTypingHideInMessagesKey = @"HideInMessages";
static NSString *const kHBTSPreferencesTypingTimeoutKey = @"TypingTimeout";

static NSString *const kHBTSPreferencesReadStatusKey = @"ReadStatus";
static NSString *const kHBTSPreferencesReadIconKey = @"ReadIcon";
static NSString *const kHBTSPreferencesReadHideInMessagesKey = @"HideReadInMessages";

static NSString *const kHBTSPreferencesOverlayAnimationSlideKey = @"OverlaySlide";
static NSString *const kHBTSPreferencesOverlayAnimationFadeKey = @"OverlayFade";
static NSString *const kHBTSPreferencesOverlayDurationKey = @"OverlayDuration";

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
		_preferences = [[HBPreferences alloc] initWithIdentifier:kHBTSPreferencesDomain];

		_typingType = HBTSNotificationTypeNone;
		_readType = HBTSNotificationTypeNone;

		[_preferences registerDefaults:@{
			kHBTSPreferencesTypingStatusKey: @YES,
			kHBTSPreferencesTypingIconKey: @NO,

			kHBTSPreferencesReadStatusKey: @YES,
			kHBTSPreferencesReadIconKey: @NO,

			kHBTSPreferencesOverlayAnimationSlideKey: @YES,
			kHBTSPreferencesOverlayAnimationFadeKey: @YES
		}];

		[_preferences registerPreferenceChangeBlock:^{
			if ([_preferences boolForKey:kHBTSPreferencesTypingStatusKey]) {
				_typingType = HBTSNotificationTypeOverlay;
			} else if ([_preferences boolForKey:kHBTSPreferencesTypingIconKey]) {
				_typingType = HBTSNotificationTypeIcon;
			} else {
				_typingType = HBTSNotificationTypeNone;
			}

			if ([_preferences boolForKey:kHBTSPreferencesReadStatusKey]) {
				_readType = HBTSNotificationTypeOverlay;
			} else if ([_preferences boolForKey:kHBTSPreferencesReadIconKey]) {
				_readType = HBTSNotificationTypeIcon;
			} else {
				_readType = HBTSNotificationTypeNone;
			}

			_overlayAnimation = HBTSStatusBarAnimationNone;

			if ([_preferences boolForKey:kHBTSPreferencesOverlayAnimationSlideKey]) {
				_overlayAnimation |= HBTSStatusBarAnimationSlide;
			}

			if ([_preferences boolForKey:kHBTSPreferencesOverlayAnimationFadeKey]) {
				_overlayAnimation |= HBTSStatusBarAnimationFade;
			}
		}];

		[_preferences registerBool:&_typingHideInMessages default:YES forKey:kHBTSPreferencesTypingHideInMessagesKey];
		[_preferences registerBool:&_readHideInMessages default:YES forKey:kHBTSPreferencesReadHideInMessagesKey];

		[_preferences registerBool:&_useTypingTimeout default:NO forKey:kHBTSPreferencesTypingTimeoutKey];
		[_preferences registerDouble:&_overlayDisplayDuration default:5.0 forKey:kHBTSPreferencesOverlayDurationKey];
	}

	return self;
}

@end
