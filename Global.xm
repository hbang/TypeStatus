#import "Global.h"
#import "HBTSStatusBarView.h"
#import <Foundation/NSUserDefaults+Private.h>

%ctor {
	prefsBundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatus.bundle"] retain];

	userDefaults = [[NSUserDefaults alloc] _initWithSuiteName:kHBTSPreferencesDomain container:[NSURL URLWithString:@"/var/mobile"]];
	[userDefaults registerDefaults:@{
		kHBTSPreferencesTypingStatusKey: @YES,
		kHBTSPreferencesTypingIconKey: @NO,
		kHBTSPreferencesTypingHideInMessagesKey: @YES,
		kHBTSPreferencesTypingTimeoutKey: @NO,

		kHBTSPreferencesReadStatusKey: @YES,
		kHBTSPreferencesReadIconKey: @NO,
		kHBTSPreferencesReadHideInMessagesKey: @YES,

		kHBTSPreferencesOverlayAnimationSlideKey: @YES,
		kHBTSPreferencesOverlayAnimationFadeKey: @YES,
		kHBTSPreferencesOverlayDurationKey: @5.f
	}];
}
