#import "../api/HBTSNotification+Private.h"
#import "HBTSStatusBarIconController.h"
#import "HBTSPreferences.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <libstatusbar/LSStatusBarItem.h>
#include <dlfcn.h>

@interface HBTSStatusBarIconController ()

+ (instancetype)sharedInstance;

@end

@implementation HBTSStatusBarIconController {
	NSTimer *_timer;
	NSMutableDictionary <NSString *, LSStatusBarItem *> *_statusBarItems;
}

+ (BOOL)_hasLibstatusbar {
	// is libstatusbar loaded? if not, let’s try dlopening it
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

+ (instancetype)sharedInstance {
	static HBTSStatusBarIconController *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

#pragma mark - NSObject

- (instancetype)init {
	self = [super init];

	if (self) {
		_statusBarItems = [NSMutableDictionary dictionary];

		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(_receivedStatusNotification:) name:HBTSClientSetStatusBarNotification object:nil];
	}

	return self;
}

#pragma mark - Notification

- (void)_receivedStatusNotification:(NSNotification *)nsNotification {
	// grab all the data
	HBTSNotification *notification = [[HBTSNotification alloc] initWithDictionary:nsNotification.userInfo];

	// when apps are paused in the background, notifications get queued up and delivered when they
	// resume. to work around this, we determine if it’s been longer than the specified duration; if
	// so, disregard the alert
	if (notification.direction && [[NSDate date] timeIntervalSinceDate:notification.date] > notification.timeout) {
		return;
	}

	// show it! (or hide it)
	if (notification.direction) {
		[self showIcon:notification.statusBarIconName timeout:notification.timeout];
	} else {
		[self hide];
	}
}

#pragma mark - Show/hide

- (void)showIcon:(NSString *)iconName timeout:(NSTimeInterval)timeout {
	// if we don’t have libstatusbar, do nothing
	if (!self.class._hasLibstatusbar) {
		return;
	}

	// if we already have a timer, kill it
	if (_timer) {
		[_timer invalidate];
		_timer = nil;
	}

	// get the item
	LSStatusBarItem *item = _statusBarItems[iconName];

	// does it not exist yet? create it
	if (!item) {
		item = [[%c(LSStatusBarItem) alloc] initWithIdentifier:[NSString stringWithFormat:@"ws.hbang.typestatus.icon-%@", iconName] alignment:StatusBarAlignmentRight];
		item.imageName = iconName;
		_statusBarItems[iconName] = item;
	}

	// show the icon
	item.visible = YES;

	// if the timeout isn’t provided, grab it from the prefs
	if (timeout == -1) {
		timeout = ((HBTSPreferences *)[%c(HBTSPreferences) sharedInstance]).overlayDisplayDuration;
	}

	// set up the hide timer
	_timer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(hide) userInfo:nil repeats:NO];
}

- (void)hide {
	// loop over all known items
	for (LSStatusBarItem *item in _statusBarItems.allValues) {
		// hide it
		item.visible = NO;
	}
}

@end

%ctor {
	[HBTSStatusBarIconController sharedInstance];
}
