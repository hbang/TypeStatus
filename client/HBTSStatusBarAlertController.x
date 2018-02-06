#import "HBTSStatusBarAlertController.h"
#import "HBTSStatusBarForegroundView.h"
#import "HBTSPreferences.h"
#import "../api/HBTSNotification+Private.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <MobileGestalt/MobileGestalt.h>
#import <SpringBoard/SBChevronView.h>
#import <SpringBoard/SBHomeGrabberView.h>
#import <SpringBoard/SBLockScreenManager.h>
#import <SpringBoard/SBLockScreenViewController.h>
#import <SpringBoard/SBLockScreenView.h>
#import <UIKit/UIStatusBar.h>
#import <version.h>

@interface UIStatusBar ()

@property (nonatomic, retain) HBTSStatusBarForegroundView *_typeStatus_foregroundView;

- (void)_typeStatus_changeToDirection:(BOOL)direction animated:(BOOL)animated;

@end

@interface SBHomeGrabberView (TypeStatus)

@property (nonatomic, strong) HBTSStatusBarForegroundView *_typeStatus_foregroundView;

- (void)_typeStatus_changeToDirection:(BOOL)direction animated:(BOOL)animated;
- (void)_typeStatus_sizeToFitForegroundView;

@end

@implementation HBTSStatusBarAlertController {
	NSMutableSet <UIStatusBar *> *_statusBars;
	NSMutableSet <SBHomeGrabberView *> *_homeGrabbers;
	dispatch_queue_t _queue;

	BOOL _visible;
	NSString *_currentIconName;
	NSString *_currentText;
	NSRange _currentBoldRange;

	BOOL _topGrabberWasHidden;
	NSTimer *_timeoutTimer;
}

+ (BOOL)isHomeBarDevice {
	if (IS_IOS_OR_NEWER(iOS_11_0)) {
		NSNumber *homeButtonType = (__bridge NSNumber *)MGCopyAnswer(CFSTR("HomeButtonType"));
		return homeButtonType != nil && homeButtonType.integerValue == 2;
	}

	return NO;
}

+ (instancetype)sharedInstance {
	static HBTSStatusBarAlertController *sharedInstance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

#pragma mark - Instance

- (instancetype)init {
	self = [super init];

	if (self) {
		_statusBars = [[NSMutableSet alloc] init];
		_homeGrabbers = [[NSMutableSet alloc] init];

		// we use a serial queue to avoid racing whenever we access the status bars set, or the other
		// status bar alert values
		_queue = dispatch_queue_create("ws.hbang.typestatus.statusbarcontrollerqueue", DISPATCH_QUEUE_SERIAL);

		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(_receivedStatusNotification:) name:HBTSClientSetStatusBarNotification object:nil];
	}

	return self;
}

#pragma mark - Status Bar Management

- (void)addStatusBar:(UIStatusBar *)statusBar {
	dispatch_async(_queue, ^{
		if ([_statusBars containsObject:statusBar]) {
			HBLogWarn(@"attempting to add a status bar that’s already known");
		}

		[_statusBars addObject:statusBar];
	});
}

- (void)removeStatusBar:(UIStatusBar *)statusBar {
	// this must be synchronous, because this method is called when a status bar is deallocating. if
	// we’re too late, the status bar is already deallocated and we crash!
	dispatch_sync(_queue, ^{
		[_statusBars removeObject:statusBar];
	});
}

- (void)addHomeGrabber:(SBHomeGrabberView *)homeGrabber {
	dispatch_async(_queue, ^{
		if ([_homeGrabbers containsObject:homeGrabber]) {
			HBLogWarn(@"attempting to add a home bar that’s already known");
		}

		[_homeGrabbers addObject:homeGrabber];
	});
}

- (void)removeHomeGrabber:(SBHomeGrabberView *)homeGrabber {
	// this must be synchronous, because this method is called when a home bar is deallocating. if
	// we’re too late, the home bar is already deallocated and we crash!
	dispatch_sync(_queue, ^{
		[_homeGrabbers removeObject:homeGrabber];
	});
}

#pragma mark - Show/Hide

- (void)_showWithNotification:(HBTSNotification *)notification animatingInDirection:(BOOL)direction timeout:(NSTimeInterval)timeout {
	dispatch_async(_queue, ^{
		[self _setLockScreenGrabberVisible:!direction];
		[self _announceAlertWithText:notification.content];

		_currentIconName = notification.statusBarIconName;
		_currentText = notification.content;
		_currentBoldRange = notification.boldRange;

		_visible = direction;

		for (UIStatusBar *statusBar in _statusBars) {
			[self displayCurrentAlertInStatusBar:statusBar animated:YES];
		}

		for (SBHomeGrabberView *homeGrabber in _homeGrabbers) {
			[self displayCurrentAlertInHomeGrabber:homeGrabber animated:YES];
		}

		if (_timeoutTimer) {
			[_timeoutTimer invalidate];
			_timeoutTimer = nil;
		}

		if (direction) {
			dispatch_async(dispatch_get_main_queue(), ^{
				_timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(hide) userInfo:nil repeats:NO];
			});
		}
	});
}

- (void)hide {
	[self _showWithNotification:nil animatingInDirection:NO timeout:0];
}

- (void)displayCurrentAlertInStatusBar:(UIStatusBar *)statusBar animated:(BOOL)animated {
	dispatch_async(dispatch_get_main_queue(), ^{
		// if for some crazy reason we don’t have a foreground view, log that (it really shouldn’t
		// happen…) and return
		if (![statusBar respondsToSelector:@selector(_typeStatus_foregroundView)] || !statusBar._typeStatus_foregroundView) {
			HBLogWarn(@"found a status bar without a foreground view! %@", statusBar);
			return;
		}

		// animate that status bar!
		[statusBar _typeStatus_changeToDirection:_visible animated:animated];

		// if we’re animating to visible, set the new values
		if (_visible) {
			[statusBar._typeStatus_foregroundView setIconName:_currentIconName text:_currentText boldRange:_currentBoldRange];
		}
	});
}

- (void)displayCurrentAlertInHomeGrabber:(SBHomeGrabberView *)homeGrabber animated:(BOOL)animated {
	dispatch_async(dispatch_get_main_queue(), ^{
		// if we’re animating to visible, set the new values
		if (_visible) {
			[homeGrabber._typeStatus_foregroundView setIconName:_currentIconName text:_currentText boldRange:_currentBoldRange];
		}

		// animate that home bar!
		[homeGrabber _typeStatus_changeToDirection:_visible animated:animated];
	});
}

#pragma mark - Notification

- (void)_receivedStatusNotification:(NSNotification *)nsNotification {
	// grab all the data
	HBTSNotification *notification = [[HBTSNotification alloc] initWithDictionary:nsNotification.userInfo];
	BOOL direction = ((NSNumber *)nsNotification.userInfo[kHBTSMessageDirectionKey]).boolValue;
	NSTimeInterval timeout = ((NSNumber *)nsNotification.userInfo[kHBTSMessageTimeoutKey]).doubleValue;
	NSTimeInterval delta = [[NSDate date] timeIntervalSinceDate:notification.date];

	// when apps are paused in the background, notifications get queued up and delivered when they
	// resume. to work around this, we determine if it’s been longer than the specified duration; if
	// so, disregard the alert
	if (direction && delta > timeout) {
		return;
	}

	// remove the delta from the timeout, so e.g. if the timeout is 5 secs, and the current app is
	// resumed 2 secs after the alert is sent, we only show it for 3 secs
	timeout -= delta;

	// show it! (or hide it)
	[self _showWithNotification:notification animatingInDirection:direction timeout:timeout];
}

#pragma mark - Lock Screen Grabber

- (void)_setLockScreenGrabberVisible:(BOOL)state {
	// we must be in springboard, and not on iOS 10 (which removed the grabbers)
	if (!IN_SPRINGBOARD || IS_IOS_OR_NEWER(iOS_10_0)) {
		return;
	}

	SBLockScreenManager *lockScreenManager = [%c(SBLockScreenManager) sharedInstance];

	// if the device isn’t at the lock screen, do nothing
	if (!lockScreenManager.isUILocked) {
		return;
	}

	// grab the top grabber
	SBLockScreenView *lockScreenView = (SBLockScreenView *)lockScreenManager.lockScreenViewController.view;
	SBChevronView *topGrabberView = lockScreenView.topGrabberView;

	if (state && !_topGrabberWasHidden) {
		// if visible, and it wasn’t hidden before
		topGrabberView.alpha = 1;
	} else if (!state) {
		// if hidden, store the state it was in before
		_topGrabberWasHidden = topGrabberView.alpha == 0;
		topGrabberView.alpha = 0;
	}
}

#pragma mark - Accessibility

- (void)_announceAlertWithText:(NSString *)text {
	// we must be in springboard, and we must have voiceover enabled
	if (text && IN_SPRINGBOARD && UIAccessibilityIsVoiceOverRunning()) {
		// post an announcement notification that voiceover will say
		UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, text);
	}
}

@end
