#import "HBTSStatusBarView.h"
#import <UIKit/UIStatusBar.h>
#import <version.h>

@interface UIStatusBar (TypeStatus)

- (void)_typeStatus_setup;

@end

%hook UIStatusBar

%group SteveScott
- (id)initWithFrame:(CGRect)frame showForegroundView:(BOOL)showForegroundView {
	self = %orig;

	if (self) {
		[self _typeStatus_setup];
	}

	return self;
}
%end

%group JonyCraig
- (id)initWithFrame:(CGRect)frame showForegroundView:(BOOL)showForegroundView inProcessStateProvider:(id)stateProvider {
	self = %orig;

	if (self) {
		[self _typeStatus_setup];
	}

	return self;
}
%end

%new - (void)_typeStatus_setup {
	[self addSubview:[[HBTSStatusBarView alloc] initWithFrame:self.bounds]];
}

%end

%ctor {
	if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.accessibility.AccessibilityUIServer"]) {
		return;
	}

	if (IS_IOS_OR_NEWER(iOS_7_0)) {
		%init(JonyCraig);
	} else {
		%init(SteveScott);
	}

	%init;
}
