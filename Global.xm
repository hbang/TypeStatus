#import "Global.h"
#import "HBTSStatusBarView.h"

%ctor {
	prefsBundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatus.bundle"] retain];
}

#pragma mark - Preferences management

void HBTSLoadPrefs() {
	/*
	 AccessibilityUIServer is an xpc service which unfortunately calls
	 UIApplicationMain() and thus UIApplicationDidFinishLaunchingNotification
	 is sent. as it has no status bar UI it just crashes out constantly...
	*/
	if ([[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.accessibility.AccessibilityUIServer"]) {
		return;
	}

	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ws.hbang.typestatus.plist"];

#if SPRINGBOARD || IMAGENT
	typingHideInMessages = GET_BOOL(@"HideInMessages", YES);
	readHideInMessages = GET_BOOL(@"HideReadInMessages", YES);
	typingIcon = GET_BOOL(@"TypingIcon", NO);
	typingStatus = GET_BOOL(@"TypingStatus", YES);
	readStatus = GET_BOOL(@"ReadStatus", YES);
#endif

	overlaySlide = GET_BOOL(@"OverlaySlide", YES);
	overlayFade = GET_BOOL(@"OverlayFade", YES);
	overlayDuration = GET_FLOAT(@"OverlayDuration", 5.f);
	typingTimeout = GET_BOOL(@"TypingTimeout", NO);

	if (firstLoad) {
		firstLoad = NO;
	} else {
#if IMAGENT
		if (!typingIcon || !typingStatus) {
			typingIndicators = 1;
			HBTSTypingEnded();
		} else if (!readStatus) {
			HBTSPostMessage(HBTSStatusBarTypeRead, nil, NO);
		}
#endif
	}

#if !IMAGENT && !SPRINGBOARD
	if (overlayView) {
		overlayView.shouldSlide = overlaySlide;
		overlayView.shouldFade = overlayFade;
	}
#endif
}
