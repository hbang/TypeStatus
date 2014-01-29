#import "Global.h"
#import "HBTSStatusBarView.h"

%ctor {
	prefsBundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatus.bundle"] retain];
}

#pragma mark - Preferences management

void HBTSLoadPrefs() {
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ws.hbang.typestatus.plist"];

#if IMAGENT
	typingHideInMessages = GET_BOOL(@"HideInMessages", YES);
	readHideInMessages = GET_BOOL(@"HideReadInMessages", YES);
	typingIcon = GET_BOOL(@"TypingIcon", NO);
	typingStatus = GET_BOOL(@"TypingStatus", YES);
	readStatus = GET_BOOL(@"ReadStatus", YES);
	shouldUndim = GET_BOOL(@"Undim", YES);
	useBulletin = GET_BOOL(@"LockScreenBulletin", YES);
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
			HBTSTypingEnded();
		} else if (!readStatus) {
			HBTSPostMessage(HBTSStatusBarTypeRead, nil, NO);
		}
#endif
	}

#if !IMAGENT
	if (overlayView) {
		overlayView.shouldSlide = overlaySlide;
		overlayView.shouldFade = overlayFade;
	}
#endif
}
