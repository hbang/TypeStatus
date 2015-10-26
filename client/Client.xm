#import "HBTSStatusBarForegroundView.h"
#import "HBTSPreferences.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <SpringBoard/SBChevronView.h>
#import <SpringBoard/SBLockScreenManager.h>
#import <SpringBoard/SBLockScreenViewController.h>
#import <SpringBoard/SBLockScreenView.h>
#import <UIKit/UIStatusBar.h>
#import <UIKit/UIStatusBarAnimationParameters.h>
#import <UIKit/UIStatusBarForegroundStyleAttributes.h>
#import <version.h>
#include <substrate.h>
#include <notify.h>

#pragma mark - UIStatusBar category

@interface UIStatusBar (TypeStatus)

@property (nonatomic, retain) HBTSStatusBarForegroundView *_typeStatus_foregroundView;
@property BOOL _typeStatus_needsNewForegroundView;

@property BOOL _typeStatus_isAnimating;
@property BOOL _typeStatus_isVisible;
@property BOOL _typeStatus_topGrabberWasHidden;

@property (nonatomic, retain) NSTimer *_typeStatus_hideTimer;

- (void)_typeStatus_animateInDirection:(BOOL)direction timeout:(NSTimeInterval)timeout;
- (void)_typeStatus_setLockScreenGrabberVisible:(BOOL)state;

@end

#pragma mark - Hooks

%hook UIStatusBar

%property (nonatomic, retain) HBTSStatusBarForegroundView *_typeStatus_foregroundView;
%property (assign) BOOL _typeStatus_needsNewForegroundView;

%property (assign) BOOL _typeStatus_isAnimating;
%property (assign) BOOL _typeStatus_isVisible;
%property (assign) BOOL _typeStatus_topGrabberWasHidden;

%property (nonatomic, retain) NSTimer *_typeStatus_hideTimer;

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame showForegroundView:(BOOL)showForegroundView inProcessStateProvider:(id)stateProvider {
	self = %orig;

	if (self) {
		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(_typeStatus_receivedStatusNotification:) name:HBTSClientSetStatusBarNotification object:nil];
	}

	return self;
}

#pragma mark - Status bar state

%group CraigFederighi

- (void)_prepareToSetStyle:(UIStatusBarStyle)style animation:(UIStatusBarAnimation)animation {
	self._typeStatus_needsNewForegroundView = YES;
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

	if (self._typeStatus_needsNewForegroundView) {
		self._typeStatus_needsNewForegroundView = NO;

		[self._typeStatus_foregroundView removeFromSuperview];
		[self._typeStatus_foregroundView release];

		UIStatusBarForegroundView *statusBarView = MSHookIvar<UIStatusBarForegroundView *>(self, "_foregroundView");

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
	}
}

#pragma mark - Notification

%new - (void)_typeStatus_receivedStatusNotification:(NSNotification *)notification {
	if (!self._typeStatus_foregroundView) {
		return;
	}

	HBTSPreferences *preferences = [HBTSPreferences sharedInstance];

	HBTSStatusBarType type = (HBTSStatusBarType)((NSNumber *)notification.userInfo[kHBTSMessageTypeKey]).intValue;
	BOOL isTyping = ((NSNumber *)notification.userInfo[kHBTSMessageIsTypingKey]).boolValue;

	NSTimeInterval duration = preferences.overlayDisplayDuration;

	if (isTyping && preferences.useTypingTimeout) {
		duration = kHBTSTypingTimeout;
	}

	if ([[NSDate date] timeIntervalSinceDate:notification.userInfo[kHBTSMessageSendDateKey]] > duration) {
		return;
	}

	[self._typeStatus_foregroundView setType:type contactName:notification.userInfo[kHBTSMessageSenderKey]];
	[self _typeStatus_animateInDirection:type != HBTSStatusBarTypeTypingEnded timeout:duration];
}

#pragma mark - Show/Hide

%new - (void)_typeStatus_animateInDirection:(BOOL)direction timeout:(NSTimeInterval)timeout {
	if (direction) {
		if (self._typeStatus_hideTimer) {
			[self._typeStatus_hideTimer invalidate];
			[self._typeStatus_hideTimer release];
			self._typeStatus_hideTimer = nil;
		}

		self._typeStatus_hideTimer = [[NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(_typeStatus_timerFired) userInfo:nil repeats:NO] retain];

		if (self._typeStatus_isVisible || self._typeStatus_isAnimating) {
			return;
		}

		self._typeStatus_isAnimating = YES;
		self._typeStatus_isVisible = YES;

		if (IN_SPRINGBOARD) {
			notify_post("ws.hbang.typestatus/OverlayWillShow");
		}
	} else {
		if (!self._typeStatus_isVisible || self._typeStatus_isAnimating) {
			return;
		}

		[self._typeStatus_hideTimer invalidate];
		[self._typeStatus_hideTimer release];
		self._typeStatus_hideTimer = nil;
	}

	HBTSStatusBarAnimation animation = [HBTSPreferences sharedInstance].overlayAnimation;

	HBTSStatusBarForegroundView *typeStatusView = self._typeStatus_foregroundView;
	UIStatusBarForegroundView *statusBarView = MSHookIvar<UIStatusBarForegroundView *>(self, "_foregroundView");

	self.clipsToBounds = YES;
	self._typeStatus_isVisible = direction;

	typeStatusView.hidden = NO;
	typeStatusView.frame = statusBarView.frame;

	statusBarView.hidden = NO;

	if (animation == HBTSStatusBarAnimationSlide) {
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

	UIStatusBarHideAnimationParameters *animationParameters = [[[%c(UIStatusBarHideAnimationParameters) alloc] initWithDefaultParameters] autorelease];

	[%c(UIStatusBarAnimationParameters) animateWithParameters:(UIStatusBarAnimationParameters *)animationParameters animations:^{
		if (animation == HBTSStatusBarAnimationSlide) {
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

		[self _typeStatus_setLockScreenGrabberVisible:!direction];
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

%new - (void)_typeStatus_timerFired {
	[self _typeStatus_animateInDirection:NO timeout:0];
}

%new - (void)_typeStatus_setLockScreenGrabberVisible:(BOOL)state {
	if (!IN_SPRINGBOARD) {
		return;
	}

	SBLockScreenManager *lockScreenManager = [%c(SBLockScreenManager) sharedInstance];

	if (!lockScreenManager.isUILocked) {
		return;
	}

	SBLockScreenView *lockScreenView = (SBLockScreenView *)lockScreenManager.lockScreenViewController.view;
	SBChevronView *topGrabberView = lockScreenView.topGrabberView;

	if (state && !self._typeStatus_topGrabberWasHidden) {
		topGrabberView.alpha = 1;
	} else if (!state) {
		self._typeStatus_topGrabberWasHidden = topGrabberView.alpha == 0;
		topGrabberView.alpha = 0;
	}
}

#pragma mark - Memory management

- (void)dealloc {
	[self._typeStatus_foregroundView release];
	[self._typeStatus_hideTimer release];

	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self name:HBTSClientSetStatusBarNotification object:nil];

	%orig;
}

%end

#pragma mark - Constructor

%ctor {
	NSString *bundleIdentifier = [NSBundle mainBundle].bundleIdentifier;

	if ([bundleIdentifier isEqualToString:@"com.apple.accessibility.AccessibilityUIServer"] || [bundleIdentifier isEqualToString:@"com.apple.SafariViewService"]) {
		return;
	}

	%init;

	if (IS_IOS_OR_NEWER(iOS_9_0)) {
		%init(EddyCue);
	} else {
		%init(CraigFederighi);
	}
}
