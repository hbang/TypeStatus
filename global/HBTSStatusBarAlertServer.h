@interface HBTSStatusBarAlertServer : NSObject

+ (NSString *)textForType:(HBTSMessageType)type sender:(NSString *)sender boldRange:(out NSRange *)boldRange;

+ (void)sendAlertWithIconName:(NSString *)iconName text:(NSString *)text boldRange:(NSRange)boldRange source:(NSString *)source timeout:(NSTimeInterval)timeout;
+ (void)hide;

@end
