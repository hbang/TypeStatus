#import "HBTSStatusBarAlertController.h"
#import "HBTSStatusBarForegroundView.h"
#import "HBTSPreferences.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <SpringBoard/SBChevronView.h>
#import <SpringBoard/SBLockScreenManager.h>
#import <SpringBoard/SBLockScreenViewController.h>
#import <SpringBoard/SBLockScreenView.h>
#import <UIKit/UIStatusBar.h>

@interface UIStatusBar ()

@property (nonatomic, retain) HBTSStatusBarForegroundView *_typeStatus_foregroundView;

- (void)_typeStatus_changeToDirection:(BOOL)direction animated:(BOOL)animated;

@end

@implementation HBTSStatusBarAlertController {
	NSMutableSet *_statusBars;

	BOOL _visible;
	NSString *_currentIconName;
	NSString *_currentText;
	NSRange _currentBoldRange;

	BOOL _topGrabberWasHidden;
	NSTimer *_timeoutTimer;
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

		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(_receivedStatusNotification:) name:HBTSClientSetStatusBarNotification object:nil];
	}

	return self;
}

#pragma mark - Status Bar Management

- (void)addStatusBar:(UIStatusBar *)statusBar {
	if ([_statusBars containsObject:statusBar]) {
		HBLogWarn(@"attempting to add a status bar that’s already known");
	}

	[_statusBars addObject:statusBar];
}

- (void)removeStatusBar:(UIStatusBar *)statusBar {
	[_statusBars removeObject:statusBar];
}

#pragma mark - Show/Hide

- (void)_showWithIconName:(NSString *)iconName text:(NSString *)text boldRange:(NSRange)boldRange animatingInDirection:(BOOL)direction timeout:(NSTimeInterval)timeout {
	[self _setLockScreenGrabberVisible:!direction];
	[self _announceAlertWithText:text];

	_currentIconName = iconName;
	_currentText = text;
	_currentBoldRange = boldRange;

	_visible = direction;

	for (UIStatusBar *statusBar in _statusBars) {
		[self displayCurrentAlertInStatusBar:statusBar animated:YES];
	}

	if (direction) {
		if (_timeoutTimer) {
			[_timeoutTimer invalidate];
			_timeoutTimer = nil;
		}

		_timeoutTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(hide) userInfo:nil repeats:NO];
	} else {
		[_timeoutTimer invalidate];
		_timeoutTimer = nil;
	}
}

- (void)hide {
	[self _showWithIconName:nil text:nil boldRange:NSMakeRange(0, 0) animatingInDirection:NO timeout:0];
}

- (void)displayCurrentAlertInStatusBar:(UIStatusBar *)statusBar animated:(BOOL)animated {
	// if for some crazy reason we don’t have a foreground view, log that (it
	// really shouldn’t happen…) and return
	if (!statusBar._typeStatus_foregroundView) {
		HBLogWarn(@"found a status bar without a foreground view! %@", statusBar);
		return;
	}

	// animate that status bar!
	[statusBar _typeStatus_changeToDirection:_visible animated:animated];

	// if we’re animating to visible, set the new values
	if (_visible) {
		[statusBar._typeStatus_foregroundView setIconName:_currentIconName text:_currentText boldRange:_currentBoldRange];
	}
}

#pragma mark - Notification

- (void)_receivedStatusNotification:(NSNotification *)notification {
	NSTimeInterval timeout = ((NSNumber *)notification.userInfo[kHBTSMessageTimeoutKey]).doubleValue;

	// when apps are paused in the background, notifications get queued up and
	// delivered when they resume. to work around this, we determine if it’s
	// been longer than the specified duration; if so, disregard the alert
	if ([[NSDate date] timeIntervalSinceDate:notification.userInfo[kHBTSMessageSendDateKey]] > timeout) {
		return;
	}

	// grab all the data
	NSString *iconName = notification.userInfo[kHBTSMessageIconNameKey];
	NSString *content = notification.userInfo[kHBTSMessageContentKey];
	BOOL direction = ((NSNumber *)notification.userInfo[kHBTSMessageDirectionKey]).boolValue;

	// deserialize the bold range array to NSRange
	NSArray <NSNumber *> *boldRangeArray = notification.userInfo[kHBTSMessageBoldRangeKey];
	NSRange boldRange = NSMakeRange(boldRangeArray[0].unsignedIntegerValue, boldRangeArray[1].unsignedIntegerValue);

	// show it! (or hide it)
	[self _showWithIconName:iconName text:content boldRange:boldRange animatingInDirection:direction timeout:timeout];
}

#pragma mark - Lock Screen Grabber

- (void)_setLockScreenGrabberVisible:(BOOL)state {
	// we must be in springboard
	if (!IN_SPRINGBOARD) {
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
	if (IN_SPRINGBOARD && UIAccessibilityIsVoiceOverRunning()) {
		// post an announcement notification that voiceover will say
		UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, text);
	}
}

@end
