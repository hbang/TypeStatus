#import "HBTSServerController.h"
#include <dlfcn.h>

HBTSServerController *server;

#pragma mark - IPC

void receivedRelayedNotification(CFMachPortRef port, LMMessage *request, CFIndex size, void *info) {
	// check that we aren’t being given a message that’s too short
	if ((size_t)size < sizeof(LMMessage)) {
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

int main() {
	@autoreleasepool {
		// load TypeStatusClient so we get HBTSPreferences
		dlopen("/Library/MobileSubstrate/DynamicLibraries/TypeStatusClient.dylib", RTLD_LAZY);

		server = [[HBTSServerController alloc] init];

		kern_return_t result = LMStartService(daemonService.serverName, CFRunLoopGetCurrent(), (CFMachPortCallBack)receivedRelayedNotification);

		if (result) {
			HBLogError(@"failed to start service! result = %i", result);
		}

		// idle, waiting for something to happen
		[[NSRunLoop mainRunLoop] run];

		// if we terminate, something is wrong!
		return 1;
	}
}
