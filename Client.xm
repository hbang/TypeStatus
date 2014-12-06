#include <substrate.h>
#import "Global.h"
#import "HBTSStatusBarView.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <Foundation/NSUserDefaults+Private.h>
#import <UIKit/UIApplication+Private.h>
#import <UIKit/UIStatusBar.h>
#import <UIKit/UIStatusBarForegroundView.h>

HBTSStatusBarView *overlayView;

#pragma mark - Constructor

%ctor {
	[[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
		if (![UIApplication sharedApplication].statusBar) {
			NSLog(@"TypeStatus: uh oh. no status bar. bailing out.");
			return;
		}

		UIStatusBarForegroundView *foregroundView = MSHookIvar<UIStatusBarForegroundView *>([UIApplication sharedApplication].statusBar, "_foregroundView");

		if (!foregroundView) {
			NSLog(@"TypeStatus: uh oh. no foregroundView. bailing out.");
			return;
		}

		overlayView = [[HBTSStatusBarView alloc] initWithFrame:[UIApplication sharedApplication].statusBar.frame];
		[[UIApplication sharedApplication].statusBar addSubview:overlayView];

		[[NSDistributedNotificationCenter defaultCenter] addObserverForName:HBTSClientSetStatusBarNotification object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *notification) {
			BOOL typing = ((NSNumber *)notification.userInfo[kHBTSMessageIsTypingKey]).boolValue;
			NSTimeInterval duration = kHBTSTypingTimeout;

			if (!typing || ((NSNumber *)notification.userInfo[kHBTSPreferencesTypingTimeoutKey]).boolValue) {
				duration = ((NSNumber *)notification.userInfo[kHBTSPreferencesOverlayDurationKey]).doubleValue;
			}

			if ([[NSDate date] timeIntervalSinceDate:notification.userInfo[kHBTSMessageSendDateKey]] > duration) {
				return;
			}

			overlayView.shouldSlide = ((NSNumber *)notification.userInfo[kHBTSPreferencesOverlayAnimationSlideKey]).boolValue;
			overlayView.shouldFade = ((NSNumber *)notification.userInfo[kHBTSPreferencesOverlayAnimationFadeKey]).boolValue;
			[overlayView showWithType:(HBTSStatusBarType)((NSNumber *)notification.userInfo[kHBTSMessageTypeKey]).intValue name:notification.userInfo[kHBTSMessageSenderKey] timeout:duration];
		}];
	}];
}
