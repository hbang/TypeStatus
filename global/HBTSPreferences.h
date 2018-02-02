@interface HBTSPreferences : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic) HBTSNotificationType typingAlertType, readAlertType, sendingFileAlertType;

@property (nonatomic, readonly) BOOL typingHideInMessages, readHideInMessages, sendingFileHideInMessages;

@property (nonatomic, readonly) BOOL useTypingTimeout;

@property (nonatomic, readonly) BOOL reduceMotion;
@property (nonatomic, readonly) NSTimeInterval overlayDisplayDuration;
@property (nonatomic, readonly) HBTSStatusBarFormat overlayFormat;

@property (nonatomic, readonly) BOOL ignoreDNDSenders;

@property (nonatomic, readonly) BOOL messagesEnabled, messagesGlobalSendTyping;

- (BOOL)isProviderEnabled:(NSString *)appIdentifier;

@end
