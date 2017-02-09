@interface HBTSPreferences : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic) HBTSNotificationType typingAlertType;
@property (nonatomic) HBTSNotificationType readAlertType;
@property (nonatomic) HBTSNotificationType sendingFileAlertType;

@property (nonatomic, readonly) BOOL typingHideInMessages;
@property (nonatomic, readonly) BOOL readHideInMessages;
@property (nonatomic, readonly) BOOL sendingFileHideInMessages;

@property (nonatomic, readonly) BOOL useTypingTimeout;

@property (nonatomic, readonly) HBTSStatusBarAnimation overlayAnimation;
@property (nonatomic, readonly) NSTimeInterval overlayDisplayDuration;
@property (nonatomic, readonly) HBTSStatusBarFormat overlayFormat;

@property (nonatomic, readonly) BOOL ignoreDNDSenders;

@property (nonatomic, readonly) BOOL messagesEnabled;

@end
