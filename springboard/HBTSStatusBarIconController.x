#import "HBTSStatusBarIconController.h"
#import "HBTSPreferences.h"
#import <libstatusbar/LSStatusBarItem.h>

NSTimer *timer;
NSMutableDictionary <NSString *, LSStatusBarItem *> *statusBarItems;

@implementation HBTSStatusBarIconController

+ (NSString *)_iconNameForType:(HBTSMessageType)type {
	switch (type) {
		case HBTSMessageTypeTyping:
		case HBTSMessageTypeTypingEnded:
			return @"TypeStatus";
			break;

		case HBTSMessageTypeReadReceipt:
			return @"TypeStatusRead";
			break;
		
		case HBTSMessageTypeSendingFile:
			return @"TypeStatus";
			break;
	}
}

+ (BOOL)_hasLibstatusbar {
	// is libstatusbar loaded? if not, let's try dlopening it
	if (!%c(LSStatusBarItem)) {
		dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);
	}

	// still not loaded? probably not installed. just bail out
	if (!%c(LSStatusBarItem)) {
		HBLogWarn(@"attempting to display a status bar icon, but libstatusbar isn’t installed");
		return NO;
	}

	return YES;
}

+ (void)showIcon:(NSString *)iconName timeout:(NSTimeInterval)timeout {
	// if we don’t have libstatusbar, do nothing
	if (!self._hasLibstatusbar) {
		return;
	}

	// if we already have a timer, kill it
	if (timer) {
		[timer invalidate];
		timer = nil;
	}

	// get the item
	LSStatusBarItem *item = statusBarItems[iconName];

	// does it not exist yet? create it
	if (!item) {
		item = [[%c(LSStatusBarItem) alloc] initWithIdentifier:[NSString stringWithFormat:@"ws.hbang.typestatus.icon-%@", iconName] alignment:StatusBarAlignmentRight];
		item.imageName = iconName;
		statusBarItems[iconName] = item;
	}

	// show the icon
	item.visible = YES;

	// if the timeout isn’t provided, grab it from the prefs
	if (timeout == -1) {
		timeout = ((HBTSPreferences *)[%c(HBTSPreferences) sharedInstance]).overlayDisplayDuration;
	}

	// set up the hide timer
	timer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(hide) userInfo:nil repeats:NO];
}

+ (void)showIconType:(HBTSMessageType)type timeout:(NSTimeInterval)timeout {
	switch (type) {
		case HBTSMessageTypeTyping:
		case HBTSMessageTypeReadReceipt:
		case HBTSMessageTypeSendingFile:
			[self showIcon:[self _iconNameForType:type] timeout:timeout];
			break;

		case HBTSMessageTypeTypingEnded:
			[self hide];
			break;
	}
}

+ (void)hide {
	// loop over all known items
	for (LSStatusBarItem *item in statusBarItems.allValues) {
		// hide it
		item.visible = NO;
	}
}

@end

%ctor {
	statusBarItems = [NSMutableDictionary dictionary];
}
