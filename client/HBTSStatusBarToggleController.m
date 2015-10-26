#import "HBTSStatusBarToggleController.h"

@implementation HBTSStatusBarToggleController {
	BOOL _statusBarWasHidden;
}

+ (void)load {
	[super load];
}

+ (void)receivedNotification:(NSNotification *)notification {
	UIStatusBarAnimationParameters *animationParameters = [[[%c(UIStatusBarHideAnimationParameters) alloc] initWithDefaultParameters] autorelease];

	if (direction && self.isHidden) {
		HBLogDebug(@"showing");
		[self setHidden:NO animationParameters:animationParameters];
	} else if (!direction && !self.isHidden && _statusBarWasHidden) {
		HBLogDebug(@"hiding");
		[self setHidden:YES animationParameters:animationParameters];
	}
}

@end
