#import "HBTSIMessageProvider+SpringBoard.h"
#import "../api/HBTSProviderController.h"
#include <dlfcn.h>

HBTSIMessageProvider *provider = nil;

#pragma mark - IPC

void ReceivedRelayedNotification(CFMachPortRef port, LMResponseBuffer *response, CFIndex size, void *info) {
	// check that we aren’t being given a message that’s too short
	if ((size_t)size < sizeof(LMMessage)) {
		HBLogError(@"received a bad message? size = %li", size);
		return;
	}

	NSDictionary <NSString *, id> *userInfo = LMResponseConsumePropertyList(response);

	// forward to the main controller
	if (!provider) {
		provider = (HBTSIMessageProvider *)[[HBTSProviderController sharedInstance] providerForAppIdentifier:@"com.apple.MobileSMS"];
	}

	[provider receivedRelayedNotification:userInfo];
}

#pragma mark - Constructor

%ctor {
	dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);
	dlopen("/Library/MobileSubstrate/DynamicLibraries/TypeStatusClient.dylib", RTLD_LAZY);

	kern_return_t result = LMStartService(springboardService.serverName, CFRunLoopGetCurrent(), (CFMachPortCallBack)ReceivedRelayedNotification);

	if (result != KERN_SUCCESS) {
		HBLogError(@"failed to start service! result = %i", result);
	}
}
