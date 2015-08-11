#import "HBTSStatusBarAlertTypeItemView.h"
#import <UIKit/_UILegibilityImageSet.h>

%subclass HBTSStatusBarAlertTypeItemView : UIStatusBarItemView

%property (nonatomic, retain) NSNumber *alertType;

- (_UILegibilityImageSet *)contentsImage {
	static NSBundle *PrefsBundle;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		PrefsBundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatus.bundle"] retain];
	});

	HBTSStatusBarType type = (HBTSStatusBarType)self.alertType.unsignedIntegerValue;
	NSString *text = @"";

	switch (type) {
		case HBTSStatusBarTypeTyping:
			text = [PrefsBundle localizedStringForKey:@"Typing:" value:@"Typing:" table:@"Root"];
			break;

		case HBTSStatusBarTypeRead:
			text = [PrefsBundle localizedStringForKey:@"Read:" value:@"Read:" table:@"Root"];
			break;

		case HBTSStatusBarTypeTypingEnded:
			break;
	}

	return [self imageWithText:text];
}

- (NSTextAlignment)textAlignment {
	return NSTextAlignmentCenter;
}

- (UIStatusBarItemViewTextStyle)textStyle {
	return UIStatusBarItemViewTextStyleBold;
}

- (void)dealloc {
	[self.alertType release];
	%orig;
}

%end
