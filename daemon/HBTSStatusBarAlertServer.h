@interface HBTSStatusBarAlertServer : NSObject

+ (void)sendAlertWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content;
+ (void)sendAlertWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content animatingInDirection:(BOOL)direction timeout:(NSTimeInterval)timeout;

+ (void)hide;

@end

