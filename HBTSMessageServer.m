#import "Global.h"
#import "HBTSMessageServer.h"
#import <AppSupport/CPDistributedMessagingCenter.h>

@implementation HBTSMessageServer
- (id)init {
	self = [super init];

	if (self) {
		CPDistributedMessagingCenter *messagingCenter = [CPDistributedMessagingCenter centerNamed:@"ws.hbang.typestatus.server"];
		[messagingCenter runServerOnCurrentThread];
		[messagingCenter registerForMessageName:@"GetState" target:self selector:@selector(_receivedMessage:userInfo:)];
	}

	return self;
}

- (NSDictionary *)_receivedMessage:(NSString *)message userInfo:(NSDictionary *)userInfo {
	if ([message isEqualToString:@"GetState"]) {
		return currentName ? [NSDictionary dictionaryWithObjectsAndKeys:
			[NSNumber numberWithInt:currentType], @"Type",
			currentName, @"Name",
			[NSNumber numberWithBool:currentTyping], @"Typing",
			nil] : [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"Reset"];
	}

	return [NSDictionary dictionary];
}

@end
