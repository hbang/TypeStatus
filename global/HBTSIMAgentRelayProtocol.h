@protocol HBTSIMAgentRelayProtocol

@required

- (void)sendNotificationWithStatusBarType:(HBTSStatusBarType)statusBarType senderName:(NSString *)senderName isTyping:(BOOL)typing;

@end