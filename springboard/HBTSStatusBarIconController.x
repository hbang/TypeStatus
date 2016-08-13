#import "HBTSStatusBarIconController.h"
#import <libstatusbar/LSStatusBarItem.h>

static NSString *const kHBTSTimerStatusBarItemKey = @"StatusBarItem";

NSTimer *timer;
LSStatusBarItem *typingStatusBarItem, *readStatusBarItem;

@implementation HBTSStatusBarIconController

+ (LSStatusBarItem *)_itemForType:(HBTSStatusBarType)type {
	// is libstatusbar loaded? if not, let's try dlopening it
	if (!%c(LSStatusBarItem)) {
		dlopen("/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib", RTLD_LAZY);
	}

	// still not loaded? probably not installed. just bail out
	if (!%c(LSStatusBarItem)) {
		HBLogWarn(@"attempting to display a status bar icon, but libstatusbar isn’t installed");
		return nil;
	}

	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		typingStatusBarItem = [[%c(LSStatusBarItem) alloc] initWithIdentifier:@"ws.hbang.typestatus.icon" alignment:StatusBarAlignmentRight];
		typingStatusBarItem.imageName = @"TypeStatus";
		typingStatusBarItem.visible = NO;

		readStatusBarItem = [[%c(LSStatusBarItem) alloc] initWithIdentifier:@"ws.hbang.typestatus.readicon" alignment:StatusBarAlignmentRight];
		readStatusBarItem.imageName = @"TypeStatusRead";
		readStatusBarItem.visible = NO;
	});

	LSStatusBarItem *item = nil;

	switch (type) {
		case HBTSStatusBarTypeTyping:
		case HBTSStatusBarTypeTypingEnded:
			item = typingStatusBarItem;
			break;

		case HBTSStatusBarTypeRead:
			item = readStatusBarItem;
			break;
	}

	return item;
}

+ (void)_timerFired:(NSTimer *)timer {
	typingStatusBarItem.visible = NO;
	readStatusBarItem.visible = NO;
}

+ (void)showIconType:(HBTSStatusBarType)type timeout:(NSTimeInterval)timeout {
	if (timer) {
		[timer invalidate];
		timer = nil;
	}

	LSStatusBarItem *item = [self _itemForType:type];

	if (!item) {
		return;
	}

	switch (type) {
		case HBTSStatusBarTypeTyping:
		case HBTSStatusBarTypeRead:
		{
			item.visible = YES;

			timer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(_timerFired:) userInfo:@{ kHBTSTimerStatusBarItemKey: item } repeats:NO];
			break;
		}

		case HBTSStatusBarTypeTypingEnded:
		{
			item.visible = NO;
			break;
		}
	}
}

@end
