#import "Global.h"

#pragma mark - Preferences management

void HBTSLoadPrefs() {
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ws.hbang.typestatus.plist"];

#if SPRINGBOARD
	typingHideInMessages = GET_BOOL(@"HideInMessages", YES);
	readHideInMessages = GET_BOOL(@"HideReadInMessages", YES);
	typingIcon = GET_BOOL(@"TypingIcon", NO);
	typingStatus = GET_BOOL(@"TypingStatus", YES);
	readStatus = GET_BOOL(@"ReadStatus", YES);
	shouldUndim = GET_BOOL(@"Undim", YES);
#endif

	overlaySlide = GET_BOOL(@"OverlaySlide", YES);
	overlayFade = GET_BOOL(@"OverlayFade", YES);
	overlayDuration = GET_FLOAT(@"OverlayDuration", 5.f);
	typingTimeout = GET_BOOL(@"TypingTimeout", NO);

	if (firstLoad) {
		firstLoad = NO;
	} else {
#if SPRINGBOARD
		if (!typingIcon || !typingStatus) {
			HBTSTypingEnded();
		} else if (!readStatus) {
			HBTSPostMessage(HBTSStatusBarTypeRead, nil, NO);
		}
#endif
	}

#if !SPRINGBOARD
	if (overlayView) {
		overlayView.shouldSlide = overlaySlide;
		overlayView.shouldFade = overlayFade;
	}
#endif
}
