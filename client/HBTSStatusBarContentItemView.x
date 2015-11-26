#import "HBTSStatusBarContentItemView.h"

%subclass HBTSStatusBarContentItemView : UIStatusBarItemView

%property (nonatomic, retain) NSString *text;

- (_UILegibilityImageSet *)contentsImage {
	return [self imageWithText:self.text];
}

- (NSTextAlignment)textAlignment {
	return NSTextAlignmentCenter;
}

- (UIStatusBarItemViewTextStyle)textStyle {
	return UIStatusBarItemViewTextStyleRegular;
}

- (void)dealloc {
	[self.text release];
	%orig;
}

%end
