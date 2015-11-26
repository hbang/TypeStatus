#import "HBTSStatusBarAlertServer.h"
#import "HBTSPreferences.h"
#import "../client/HBTSStatusBarAlertController.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <Foundation/NSXPCConnection.h>
#import <Foundation/NSXPCInterface.h>
#import "HBTSStatusBarAlertProtocol.h"

@implementation HBTSStatusBarAlertServer

#pragma mark init

#pragma mark NSXPCConnection

+ (NSXPCConnection *)statusBarXPCConnection {
	NSXPCConnection *connection = [[NSXPCConnection alloc] initWithServiceName:kHBTSStatusBarMachServiceName];
	connection.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(HBTSStatusBarAlertProtocol)];
	[connection resume];
	return connection;
}

#pragma mark TypeStatus

+ (NSString *)iconNameForType:(HBTSStatusBarType)type {
	NSString *name = nil;

	switch (type) {
		case HBTSStatusBarTypeTyping:
			name = @"TypeStatus";
			break;

		case HBTSStatusBarTypeRead:
			name = @"TypeStatusRead";
			break;

		case HBTSStatusBarTypeTypingEnded:
			break;
	}

	return name;
}

+ (NSString *)titleForType:(HBTSStatusBarType)type {
	static NSBundle *PrefsBundle;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		PrefsBundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatus.bundle"] retain];
	});

	NSString *text = @"";

	switch (type) {
		case HBTSStatusBarTypeTyping:
			text = [PrefsBundle localizedStringForKey:@"TYPING" value:nil table:@"Localizable"];
			break;

		case HBTSStatusBarTypeRead:
			text = [PrefsBundle localizedStringForKey:@"READ" value:nil table:@"Localizable"];
			break;

		case HBTSStatusBarTypeTypingEnded:
			break;
	}

	return text;
}

#pragma mark - Send

+ (void)sendAlertWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content {
	[self sendAlertWithIconName:iconName title:title content:content animatingInDirection:YES timeout:-1];
}

+ (void)sendAlertWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content animatingInDirection:(BOOL)direction timeout:(NSTimeInterval)timeout {
	if (timeout == -1) {
		timeout = ((HBTSPreferences *)[%c(HBTSPreferences) sharedInstance]).overlayDisplayDuration;
	}

	HBTSStatusBarAlertController *statusBarAlertController = [[self statusBarXPCConnection] remoteObjectProxyWithErrorHandler:^(NSError *error){
		if (error) {
			HBLogError(@"Could not send notification via XPC: %@", error);
			return;
		}
	}];

	[statusBarAlertController sendNotificationWithIconName:iconName title:title content:content direction:direction timeout:timeout sendDate:[NSDate date]];

}

+ (void)sendAlertType:(HBTSStatusBarType)type sender:(NSString *)sender timeout:(NSTimeInterval)timeout {
	NSString *iconName = [self iconNameForType:type];
	NSString *title = [self titleForType:type];
	BOOL direction = type != HBTSStatusBarTypeTypingEnded;

	[self sendAlertWithIconName:iconName title:title content:sender animatingInDirection:direction timeout:timeout];
}

+ (void)hide {
	[self sendAlertWithIconName:nil title:nil content:nil animatingInDirection:NO timeout:0];
}

@end
