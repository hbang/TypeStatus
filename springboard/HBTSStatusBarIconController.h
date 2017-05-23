@interface HBTSStatusBarIconController : NSObject

+ (void)showIcon:(NSString *)iconName timeout:(NSTimeInterval)timeout;
+ (void)showIconType:(HBTSMessageType)type timeout:(NSTimeInterval)timeout;

+ (void)hide;

@end
