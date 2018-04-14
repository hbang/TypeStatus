#import "HBTSStatusBarForegroundView.h"
#import "HBTSStatusBarAlertController.h"
#import "HBTSPreferences.h"
#import <UIKit/UIStatusBar.h>
#import <UIKit/UIStatusBarAnimationParameters.h>
#import <version.h>
#include <notify.h>

#pragma mark - UIStatusBar category

@interface UIStatusBar (TypeStatus)

@property (nonatomic, retain) HBTSStatusBarForegroundView *_typeStatus_foregroundView;
@property BOOL _typeStatus_needsNewForegroundView;

@property BOOL _typeStatus_isAnimating;
@property BOOL _typeStatus_isVisible;

- (BOOL)_typeStatus_isStatusBarWeird;
- (void)_typeStatus_changeToDirection:(BOOL)direction animated:(BOOL)animated;

@end

#pragma mark - Hooks

%hook UIStatusBar

%property (nonatomic, retain) HBTSStatusBarForegroundView *_typeStatus_foregroundView;
%property (assign) BOOL _typeStatus_needsNewForegroundView;

%property (assign) BOOL _typeStatus_isAnimating;
%property (assign) BOOL _typeStatus_isVisible;

#pragma mark - Initialization

%group PhilSchiller

- (instancetype)initWithFrame:(CGRect)frame showForegroundView:(BOOL)showForegroundView inProcessStateProvider:(id)stateProvider {
	%orig;

	if (self) {
		if (!self._typeStatus_isStatusBarWeird) {
			[[HBTSStatusBarAlertController sharedInstance] addStatusBar:self];
		}
	}

	return self;
}

%end

%group AngelaAhrendts

- (instancetype)_initWithFrame:(CGRect)frame showForegroundView:(BOOL)showForegroundView inProcessStateProvider:(id)stateProvider {
	%orig;

	if (self) {
		// TODO: how the hell are we ending up here, where self is a UIStatusBar_Modern (iPhone X status
		// bar), but UIStatusBar_Modern doesn’t inherit from UIStatusBar, nor vice versa?
		if (!self._typeStatus_isStatusBarWeird) {
			[[HBTSStatusBarAlertController sharedInstance] addStatusBar:self];
		}
	}

	return self;
}

%end

%new - (BOOL)_typeStatus_isStatusBarWeird {
	return [self isKindOfClass:%c(SBFakeStatusBarView)]
		|| [self isKindOfClass:%c(UIStatusBar_Modern)]
		|| [self.window isKindOfClass:%c(SBStarkStatusBarWindow)];
}

#pragma mark - Status bar state

%group CraigFederighi

- (void)_prepareToSetStyle:(UIStatusBarStyle)style animation:(UIStatusBarAnimation)animation {
	self._typeStatus_needsNewForegroundView = !self._typeStatus_isStatusBarWeird;
	%orig;
}

%end

%group EddyCue

- (void)_prepareToSetStyle:(UIStatusBarStyle)style animation:(UIStatusBarAnimation)animation forced:(BOOL)forced {
	self._typeStatus_needsNewForegroundView = YES;
	%orig;
}

%end

- (void)_swapToNewForegroundView {
	%orig;

	// if we don’t need a new foreground view, we have nothing to do here. just return
	if (!self._typeStatus_needsNewForegroundView) {
		return;
	}

	self._typeStatus_needsNewForegroundView = NO;

	[self._typeStatus_foregroundView removeFromSuperview];

	UIStatusBarForegroundView *statusBarView = [self valueForKey:@"_foregroundView"];
	HBTSStatusBarForegroundView *typeStatusView;

	if ([%c(HBTSStatusBarForegroundView) instancesRespondToSelector:@selector(initWithFrame:foregroundStyle:usesVerticalLayout:)]) {
		typeStatusView = [[%c(HBTSStatusBarForegroundView) alloc] initWithFrame:statusBarView.frame foregroundStyle:statusBarView.foregroundStyle usesVerticalLayout:NO];
	} else {
		typeStatusView = [[%c(HBTSStatusBarForegroundView) alloc] initWithFrame:statusBarView.frame foregroundStyle:statusBarView.foregroundStyle];
	}

	typeStatusView.statusBarView = statusBarView;
	typeStatusView.hidden = YES;
	[self insertSubview:typeStatusView aboveSubview:statusBarView];

	self._typeStatus_foregroundView = typeStatusView;

	[[HBTSStatusBarAlertController sharedInstance] displayCurrentAlertInStatusBar:self animated:NO];
}

#pragma mark - Show/Hide

%new - (void)_typeStatus_changeToDirection:(BOOL)direction animated:(BOOL)animated {
	if (!self._typeStatus_foregroundView) {
		return;
	}

	if (direction) {
		if (self._typeStatus_isVisible || self._typeStatus_isAnimating) {
			return;
		}

		self._typeStatus_isAnimating = YES;

		if (IN_SPRINGBOARD) {
			notify_post("ws.hbang.typestatus/OverlayWillShow");
		}
	} else if (!self._typeStatus_isVisible || self._typeStatus_isAnimating) {
		return;
	}

	BOOL reduceMotion = [HBTSPreferences sharedInstance].reduceMotion;

	HBTSStatusBarForegroundView *typeStatusView = self._typeStatus_foregroundView;
	UIStatusBarForegroundView *statusBarView = [self valueForKey:@"_foregroundView"];

	self.clipsToBounds = YES;
	self._typeStatus_isVisible = direction;

	typeStatusView.hidden = NO;
	typeStatusView.frame = statusBarView.frame;

	statusBarView.hidden = NO;

	if (!reduceMotion) {
		CGRect typeStatusFrame = typeStatusView.frame;
		typeStatusFrame.origin.y = direction ? -typeStatusFrame.size.height : 0;
		typeStatusView.frame = typeStatusFrame;

		CGRect statusBarFrame = statusBarView.frame;
		statusBarFrame.origin.y = direction ? 0 : statusBarFrame.size.height;
		statusBarFrame.size.height = direction ? typeStatusFrame.size.height : 0;
		statusBarView.frame = statusBarFrame;
	}

	typeStatusView.alpha = direction ? 0 : 1;
	statusBarView.alpha = direction ? 1 : 0;

	UIStatusBarHideAnimationParameters *animationParameters = animated ? [[%c(UIStatusBarHideAnimationParameters) alloc] initWithDefaultParameters] : nil;

	[%c(UIStatusBarAnimationParameters) animateWithParameters:(UIStatusBarAnimationParameters *)animationParameters animations:^{
		if (!reduceMotion) {
			CGRect typeStatusFrame = typeStatusView.frame;
			typeStatusFrame.origin.y = direction ? 0 : -typeStatusFrame.size.height;
			typeStatusView.frame = typeStatusFrame;

			CGRect statusBarFrame = statusBarView.frame;
			statusBarFrame.origin.y = direction ? typeStatusFrame.size.height : 0;
			statusBarFrame.size.height = direction ? 0 : typeStatusFrame.size.height;
			statusBarView.frame = statusBarFrame;
		}

		typeStatusView.alpha = direction ? 1 : 0;
		statusBarView.alpha = direction ? 0 : 1;
	} completion:^(BOOL finished) {
		if (!statusBarView) {
			HBLogWarn(@"statusBarView == nil?!");
			return;
		}

		if (!typeStatusView) {
			HBLogWarn(@"typeStatusView == nil?!");
			return;
		}

		statusBarView.alpha = 1;
		statusBarView.hidden = direction;

		CGRect statusBarFrame = statusBarView.frame;
		statusBarFrame.origin.y = 0;
		statusBarFrame.size.height = typeStatusView.frame.size.height;
		statusBarView.frame = statusBarFrame;

		typeStatusView.hidden = !direction;

		self.clipsToBounds = NO;
		self._typeStatus_isAnimating = NO;

		if (!direction && IN_SPRINGBOARD) {
			notify_post("ws.hbang.typestatus/OverlayDidHide");
		}
	}];
}

- (void)dealloc {
	[[HBTSStatusBarAlertController sharedInstance] removeStatusBar:self];

	%orig;
}

%end

// this is for the weirdo iphone x status bar thing i kinda sorta mentioned above

%group WTFiPhoneX
%hook UIStatusBar_Modern

%new - (BOOL)_typeStatus_isStatusBarWeird {
	return YES;
}

%end
%end

#pragma mark - Constructor

%ctor {
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *bundleIdentifier = bundle.bundleIdentifier;
	NSDictionary <NSString *, id> *infoPlist = bundle.infoDictionary;

	// blacklist:
	// • AccessibilityUIServer (has no status bar anyway)
	// • SafariViewService (no idea why it crashes…)
	// • app extensions/plugins (can have a pretty locked down sandbox)
	if ([bundleIdentifier isEqualToString:@"com.apple.accessibility.AccessibilityUIServer"]
		|| [bundleIdentifier isEqualToString:@"com.apple.SafariViewService"]
		|| infoPlist[@"NSExtension"] || infoPlist[@"PlugInKit"]) {
		return;
	}

	%init;

	if (IS_IOS_OR_NEWER(iOS_11_0)) {
		%init(AngelaAhrendts);
		%init(WTFiPhoneX);
	} else {
		%init(PhilSchiller);
	}

	if (IS_IOS_OR_NEWER(iOS_9_0)) {
		%init(EddyCue);
	} else {
		%init(CraigFederighi);
	}
}
