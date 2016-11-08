@interface HBTSStatusBarAlertServer : NSObject

+ (NSString *)textForType:(HBTSMessageType)type sender:(NSString *)sender boldRange:(out NSRange *)boldRange;

+ (void)sendAlertWithIconName:(NSString *)iconName text:(NSString *)text boldRange:(NSRange)boldRange timeout:(NSTimeInterval)timeout source:(NSString *)source;
+ (void)hide;

@end
