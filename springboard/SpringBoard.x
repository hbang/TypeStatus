#import "HBTSSpringBoardServer.h"
#include <dlfcn.h>

HBTSSpringBoardServer *server;

#pragma mark - IPC

void ReceivedRelayedNotification(CFMachPortRef port, LMMessage *request, CFIndex size, void *info) {
	// check that we aren’t being given a message that’s too short
	if (size < sizeof(LMMessage)) {
		HBLogError(@"received a bad message? size = %li", size);
		return;
	}

	// get the raw data sent
	const void *rawData = LMMessageGetData(request);
	size_t length = LMMessageGetDataLength(request);

	// translate to NSData, then NSDictionary
	CFDataRef data = CFDataCreateWithBytesNoCopy(kCFAllocatorDefault, (const UInt8 *)rawData, length, kCFAllocatorNull);
	NSDictionary <NSString *, id> *userInfo = LMPropertyListForData((__bridge NSData *)data);

	// forward to the main controller
	[server receivedRelayedNotification:userInfo];
}

#pragma mark - Constructor

%ctor {
	dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);
	dlopen("/Library/MobileSubstrate/DynamicLibraries/TypeStatusClient.dylib", RTLD_LAZY);

	server = [[HBTSSpringBoardServer alloc] init];

	kern_return_t result = LMStartService((char *)"ws.hbang.typestatus.springboardserver", CFRunLoopGetCurrent(), (CFMachPortCallBack)ReceivedRelayedNotification);

	if (result) {
		HBLogError(@"failed to start service! result = %i", result);
	}
}
