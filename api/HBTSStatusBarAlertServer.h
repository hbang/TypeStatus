@interface HBTSStatusBarAlertServer : NSObject

+ (NSString *)textForType:(HBTSMessageType)type sender:(NSString *)sender boldRange:(out NSRange *)boldRange;

+ (void)sendNotification:(HBTSNotification *)notification;
+ (void)hide;

@end
