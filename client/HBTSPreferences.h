@interface HBTSPreferences : NSObject

+ (instancetype)sharedInstance;

@property HBTSNotificationType typingType;
@property HBTSNotificationType readType;

@property (readonly) BOOL typingHideInMessages;
@property (readonly) BOOL readHideInMessages;

@property (readonly) BOOL useTypingTimeout;

@property (readonly) HBTSStatusBarAnimation overlayAnimation;
@property (readonly) NSTimeInterval overlayDisplayDuration;

@property (readonly) BOOL ignoreDNDSenders;

@end
