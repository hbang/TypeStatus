#import "HBTSStatusBarTitleItemView.h"

%subclass HBTSStatusBarTitleItemView : HBTSStatusBarItemView

%property (nonatomic, retain) NSString *text;

- (_UILegibilityImageSet *)contentsImage {
	return [self imageWithText:self.text];
}

- (NSTextAlignment)textAlignment {
	return NSTextAlignmentCenter;
}

- (UIStatusBarItemViewTextStyle)textStyle {
	return UIStatusBarItemViewTextStyleBold;
}

- (void)dealloc {
	[self.text release];
	%orig;
}

%end
