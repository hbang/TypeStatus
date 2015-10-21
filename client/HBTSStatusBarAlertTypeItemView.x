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
			text = [PrefsBundle localizedStringForKey:@"TYPING" value:nil table:@"Localizable"];
			break;

		case HBTSStatusBarTypeRead:
			text = [PrefsBundle localizedStringForKey:@"READ" value:nil table:@"Localizable"];
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
