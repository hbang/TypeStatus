#import "Global.h"
#import "HBTSMessageServer.h"
#import <AppSupport/CPDistributedMessagingCenter.h>

@implementation HBTSMessageServer
- (id)init {
	self = [super init];

	if (self) {
		CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:[@"ws.hbang.typestatus.server_for_app_" stringByAppendingString:[NSBundle mainBundle].bundleIdentifier]];
		[messagingCenter runServerOnCurrentThread];
		[messagingCenter registerForMessageName:@"SetState" target:self selector:@selector(_receivedMessage:userInfo:)];
	}

	return self;
}

- (NSDictionary *)_receivedMessage:(NSString *)message userInfo:(NSDictionary *)userInfo {
	if ([message isEqualToString:@"SetState"]) {
		HBTSSetStatusBar((HBTSStatusBarType)((NSNumber *)[userInfo objectForKey:@"Type"]).intValue, [userInfo objectForKey:@"Name"], ((NSNumber *)[userInfo objectForKey:@"Typing"]).boolValue);
		return [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"Success"];
	}

	return [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:@"Success"];
}

@end
