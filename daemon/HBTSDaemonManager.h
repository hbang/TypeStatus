#import <Foundation/NSXPCListener.h>
#import "HBTSIMAgentRelayProtocol.h"

@interface HBTSDaemonManager : NSObject <NSXPCListenerDelegate, HBTSIMAgentRelayProtocol>

@end