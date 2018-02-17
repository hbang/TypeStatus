#import "HBTSIMessageProvider+SpringBoard.h"
#import "../api/HBTSProviderController.h"
#include <dlfcn.h>

HBTSIMessageProvider *provider = nil;

#pragma mark - IPC

void ReceivedRelayedNotification(CFMachPortRef port, LMMessage *request, CFIndex size, void *info) {
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

#import "../api/HBTSNotification+Private.h"
#import "../api/HBTSStatusBarAlertServer.h"
%ctor {
	[NSTimer scheduledTimerWithTimeInterval:8 repeats:YES block:^(NSTimer *timer) {
		HBTSNotification*a=[[HBTSNotification alloc] initWithType:0 sender:@"kirb" iconName:@"TypeStatus"];
		a.sourceBundleID=@"com.apple.MobileSMS";
		[HBTSStatusBarAlertServer sendNotification:a];
	}];
}
