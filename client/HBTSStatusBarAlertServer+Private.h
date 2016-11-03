#import "HBTSStatusBarAlertServer.h"

@interface HBTSStatusBarAlertServer (Private)

+ (void)sendAlertType:(HBTSMessageType)type sender:(NSString *)sender timeout:(NSTimeInterval)timeout;

@end
