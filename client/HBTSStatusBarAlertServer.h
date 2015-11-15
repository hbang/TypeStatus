@interface HBTSStatusBarAlertServer : NSObject

+ (void)sendAlertWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content animatingInDirection:(BOOL)direction timeout:(NSTimeInterval)timeout;
+ (void)sendAlertType:(HBTSStatusBarType)type sender:(NSString *)sender timeout:(NSTimeInterval)timeout;

+ (void)hide;

@end

