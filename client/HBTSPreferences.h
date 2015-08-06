typedef NS_ENUM(NSUInteger, HBTSNotificationType) {
	HBTSNotificationTypeNone,
	HBTSNotificationTypeOverlay,
	HBTSNotificationTypeIcon
};

typedef NS_ENUM(NSUInteger, HBTSStatusBarAnimation) {
	HBTSStatusBarAnimationNone,
	HBTSStatusBarAnimationSlide,
	HBTSStatusBarAnimationFade
};

@interface HBTSPreferences : NSObject

+ (instancetype)sharedInstance;

@property (readonly) HBTSNotificationType typingType;
@property (readonly) HBTSNotificationType readType;

@property (readonly) BOOL typingHideInMessages;
@property (readonly) BOOL readHideInMessages;

@property (readonly) BOOL useTypingTimeout;

@property (readonly) HBTSStatusBarAnimation overlayAnimation;
@property (readonly) NSTimeInterval overlayDisplayDuration;

@end
