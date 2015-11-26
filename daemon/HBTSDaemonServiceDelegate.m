#import "HBTSDaemonServiceDelegate.h"
#import "HBTSDaemonManager.h"
#import <Foundation/NSXPCConnection.h>
#import <Foundation/NSXPCInterface.h>

@implementation HBTSDaemonServiceDelegate

#pragma mark - NSXPCListenerDelegate

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {
	newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HBTSIMAgentRelayProtocol)];
	newConnection.exportedObject = [[HBTSDaemonManager alloc] init];
	[newConnection resume];
	return YES;
}

@end
