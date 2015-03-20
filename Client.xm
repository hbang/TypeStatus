#import "HBTSStatusBarView.h"
#import <UIKit/UIStatusBar.h>
#import <version.h>

@interface UIStatusBar (TypeStatus)

- (void)_typeStatus_setup;

@end

%hook UIStatusBar

- (void)movedToWindow:(UIWindow *)window {
	%orig;

	if ([self isKindOfClass:%c(SBFakeStatusBarView)] || [window isKindOfClass:%c(SBStarkStatusBarWindow)]) {
		return;
	}

	[self addSubview:[[HBTSStatusBarView alloc] initWithFrame:self.bounds]];
}

- (void)movedFromWindow:(UIWindow *)window {
	%orig;

	for (UIView *view in self.subviews) {
		if ([view isKindOfClass:HBTSStatusBarView.class]) {
			[view removeFromSuperview];
		}
	}
}

%end

%ctor {
	if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.accessibility.AccessibilityUIServer"]) {
		return;
	}

	%init;
}
