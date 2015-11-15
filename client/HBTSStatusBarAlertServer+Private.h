@interface HBTSStatusBarAlertServer (Private)

+ (void)sendAlertType:(HBTSStatusBarType)type sender:(NSString *)sender timeout:(NSTimeInterval)timeout;

@end
