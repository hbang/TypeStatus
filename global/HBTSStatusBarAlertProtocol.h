@protocol HBTSStatusBarAlertProtocol 

@required

- (void)sendNotificationWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content direction:(BOOL)direction timeout:(NSTimeInterval)timeout sendDate:(NSDate *)sendDate;

@end