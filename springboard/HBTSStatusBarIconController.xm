#import "HBTSStatusBarIconController.h"
#import <libstatusbar/LSStatusBarItem.h>

static NSString *const kHBTSTimerKey = @"Timer";

NSTimer *timer;

@implementation HBTSStatusBarIconController

+ (LSStatusBarItem *)_itemForType:(HBTSStatusBarType)type {
	static LSStatusBarItem *TypingStatusBarItem, *ReadStatusBarItem;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		TypingStatusBarItem = [[%c(LSStatusBarItem) alloc] initWithIdentifier:@"ws.hbang.typestatus.icon" alignment:StatusBarAlignmentRight];
		TypingStatusBarItem.imageName = @"TypeStatus";

		ReadStatusBarItem = [[%c(LSStatusBarItem) alloc] initWithIdentifier:@"ws.hbang.typestatus.readicon" alignment:StatusBarAlignmentRight];
		ReadStatusBarItem.imageName = @"TypeStatusRead";
	});

	LSStatusBarItem *item;

	switch (type) {
		case HBTSStatusBarTypeTyping:
		case HBTSStatusBarTypeTypingEnded:
			item = TypingStatusBarItem;
			break;

		case HBTSStatusBarTypeRead:
			item = ReadStatusBarItem;
			break;
	}

	return item;
}

+ (void)_timerFired:(NSTimer *)timer {
	LSStatusBarItem *item = timer.userInfo[kHBTSTimerKey];
	item.visible = NO;
}

+ (void)showIconType:(HBTSStatusBarType)type timeout:(NSTimeInterval)timeout {
	if (timer) {
		[timer invalidate];
		[timer release];
		timer = nil;
	}

	LSStatusBarItem *item = [self _itemForType:type];

	switch (type) {
		case HBTSStatusBarTypeTyping:
		case HBTSStatusBarTypeRead:
		{
			item.visible = YES;

			timer = [[NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(_timerFired:) userInfo:@{ kHBTSTimerKey: item } repeats:NO] retain];
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
