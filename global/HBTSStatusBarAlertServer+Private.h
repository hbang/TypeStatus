#import "HBTSStatusBarAlertServer.h"

@interface HBTSStatusBarAlertServer (Private)

+ (void)sendMessagesAlertType:(HBTSMessageType)type sender:(NSString *)sender timeout:(NSTimeInterval)timeout;

@end
