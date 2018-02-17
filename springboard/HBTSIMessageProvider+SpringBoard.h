#import "../api/HBTSIMessageProvider.h"

@interface HBTSIMessageProvider (SpringBoard)

+ (NSString *)iconNameForType:(HBTSMessageType)type;

- (void)receivedRelayedNotification:(NSDictionary *)userInfo;
- (BOOL)_shouldShowAlertOfType:(HBTSMessageType)type;

@end
