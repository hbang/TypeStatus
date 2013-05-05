#import <libstatusbar/LSStatusBarItem.h>
#import <ChatKit/CKIMEntity.h>
#import <IMFoundation/FZMessage.h>
#import <QuartzCore/QuartzCore.h>
#import <SpringBoard/SpringBoard.h>
#import <SpringBoard/SBStatusBarDataManager.h>
#import <SpringBoard/SBUserAgent.h>
#import <UIKit/UIViewController+Private.h>
#import <UIKit/UIWindow+Private.h>
#import "HBTSStatusBarOverlayWindow.h"

int typingIndicators = 0;
LSStatusBarItem *statusBarItem;

HBTSStatusBarOverlayWindow *overlayWindow;
BOOL updatingClock = NO;
NSTimer *typingTimer;
NSBundle *prefsBundle;
BOOL isTyping = NO;
BOOL firstLoad = YES;
NSMutableDictionary *nameCache = [[NSMutableDictionary alloc] init];

BOOL typingHideInMessages = YES;
BOOL typingIcon = YES;
BOOL typingStatus = YES;
BOOL typingTimeout = NO;
BOOL readHideInMessages = YES;
BOOL readStatus = YES;
BOOL overlaySlide = YES;
BOOL overlayFade = YES;

NSArray *messagesApps = [[NSArray alloc] initWithObjects:@"com.apple.MobileSMS", @"com.bitesms", nil];

void HBTSLoadPrefs();

#define GET_BOOL(key, default) ([prefs objectForKey:key] ? [[prefs objectForKey:key] boolValue] : default)
#define I18N(key) ([prefsBundle localizedStringForKey:key value:key table:@"TypeStatus"])
#define kHBTSStatusBarTimeout 5
#define kHBTSTypingTimeout 60

#pragma mark - Hide while Messages is open

BOOL HBTSShouldHide(BOOL typing) {
	return (typing ? typingHideInMessages : readHideInMessages) ? [messagesApps containsObject:[[%c(SBUserAgent) sharedUserAgent] foregroundApplicationDisplayID]] : NO;
}

#pragma mark - Get contact name

NSString *HBTSNameForHandle(NSString *handle) {
	if ([nameCache objectForKey:handle]) {
		return [nameCache objectForKey:handle];
	} else {
		CKIMEntity *entity = [[%c(CKIMEntity) copyEntityForAddressString:handle] autorelease]; // linker hates me
		[nameCache setObject:entity.name forKey:handle];
		return entity.name;
	}
}

#pragma mark - Show/hide functions

void HBTSSetStatusBar(NSString *string, BOOL typing) {
	overlayWindow.string = string ? [string copy] : nil;

	if (string) {
		[overlayWindow showWithTimeout:typing ? kHBTSTypingTimeout : kHBTSStatusBarTimeout];
	} else {
		[overlayWindow hide];
	}
}

void HBTSTypingStarted(FZMessage *message, BOOL testing) {
	typingIndicators++;
	isTyping = YES;

	if (HBTSShouldHide(YES)) {
		return;
	}

	if (typingIcon) {
		if (!statusBarItem) {
			statusBarItem = [[%c(LSStatusBarItem) alloc] initWithIdentifier:@"ws.hbang.typestatus.icon" alignment:StatusBarAlignmentRight];
			statusBarItem.imageName = @"TypeStatus";
		}

		statusBarItem.visible = YES;

		if (typingTimer) {
			[typingTimer invalidate];
			[typingTimer release];
			typingTimer = nil;
		}

		if (typingTimeout || testing) {
			typingTimer = [[NSTimer scheduledTimerWithTimeInterval:testing ? kHBTSStatusBarTimeout : kHBTSTypingTimeout target:message selector:@selector(typeStatus_typingEnded) userInfo:nil repeats:NO] retain];
		}
	}

	if (typingStatus) {
		HBTSSetStatusBar([NSString stringWithFormat:I18N(@"Typing: %@"), HBTSNameForHandle(message.handle)], !testing);
	}
}

void HBTSTypingEnded() {
	typingIndicators--;

	if (typingIndicators <= 0) {
		typingIndicators = 0;
		isTyping = NO;
	}

	if (!isTyping) {
		if (statusBarItem) {
			statusBarItem.visible = NO;
		}

		if (typingTimer) {
			[typingTimer invalidate];
			[typingTimer release];
			typingTimer = nil;
		}

		if (typingStatus) {
			HBTSSetStatusBar(nil, NO);
		}
	}
}

void HBTSMessageRead(FZMessage *message) {
	if (readStatus && [[NSDate date] timeIntervalSinceDate:message.timeRead] < 1 && !HBTSShouldHide(NO)) {
		HBTSSetStatusBar([NSString stringWithFormat:I18N(@"Read: %@"), HBTSNameForHandle(message.handle)], NO);
	}
}

#pragma mark - Test functions

void HBTSTestTyping() {
	typingIndicators = 0;

	/*
	 We could have linked against IMFoundation, if not for it
	 being set up insanely on iOS 5:
	 IMCore.framework/Frameworks/IMFoundation.framework
	*/

	FZMessage *message = [[[%c(FZMessage) alloc] init] autorelease];
	message.handle = @"example@hbang.ws";

	HBTSTypingStarted(message, YES);
}

void HBTSTestRead() {
	FZMessage *message = [[[%c(FZMessage) alloc] init] autorelease];
	message.handle = @"example@hbang.ws";
	message.timeRead = [NSDate date];
}

#pragma mark - iMessage typing status receiver

%hook IMChatRegistry
- (void)account:(id)account chat:(id)chat style:(unsigned char)style chatProperties:(id)properties messageReceived:(FZMessage *)message {
	%orig;

	if (message.flags == 4096) {
		HBTSTypingStarted(message, NO);
	} else {
		HBTSTypingEnded();
	}
}
%end

#pragma mark - iMessage read receipt receiver

%hook FZMessage
- (void)setTimeRead:(NSDate *)timeRead {
	%orig;

	HBTSMessageRead(self);
}

%new - (void)typeStatus_typingEnded {
	HBTSTypingEnded();
}
%end

#pragma mark - Status bar overlay management

%hook SpringBoard
- (void)applicationDidFinishLaunching:(UIApplication *)application {
	%orig;

	overlayWindow = [[HBTSStatusBarOverlayWindow alloc] init];

	HBTSLoadPrefs();
}

- (void)noteInterfaceOrientationChanged:(UIInterfaceOrientation)interfaceOrientation duration:(float)duration updateMirroredDisplays:(BOOL)update force:(BOOL)force {
	%orig;

	[UIView animateWithDuration:duration animations:^{
		UIWindow *keyWindow = UIWindow.keyWindow;
		[overlayWindow makeKeyWindow];
		overlayWindow.rootViewController.interfaceOrientation = interfaceOrientation;
		[keyWindow makeKeyWindow];
	}];
}
%end

#pragma mark - Preferences management

void HBTSLoadPrefs() {
	NSDictionary *prefs = [NSDictionary dictionaryWithContentsOfFile:@"/var/mobile/Library/Preferences/ws.hbang.typestatus.plist"];

	typingHideInMessages = GET_BOOL(@"HideInMessages", YES);
	readHideInMessages = GET_BOOL(@"HideReadInMessages", YES);
	typingIcon = GET_BOOL(@"TypingIcon", YES);
	typingStatus = GET_BOOL(@"TypingStatus", YES);
	readStatus = GET_BOOL(@"ReadStatus", YES);
	overlaySlide = GET_BOOL(@"OverlaySlide", YES);
	overlayFade = GET_BOOL(@"OverlayFade", NO);

	if (!firstLoad) {
		if (!typingIcon || !typingStatus) {
			HBTSTypingEnded();
		} else if (!readStatus) {
			HBTSSetStatusBar(nil, NO);
		}
	} else {
		firstLoad = NO;
	}

	if (overlayWindow) {
		overlayWindow.shouldSlide = overlaySlide;
		overlayWindow.shouldFade = overlayFade;
	}
}

%ctor {
	prefsBundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatus.bundle"] retain];

	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)HBTSLoadPrefs, CFSTR("ws.hbang.typestatus/ReloadPrefs"), NULL, 0);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)HBTSTestTyping, CFSTR("ws.hbang.typestatus/TestTyping"), NULL, 0);
	CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)HBTSTestRead, CFSTR("ws.hbang.typestatus/TestRead"), NULL, 0);

}
