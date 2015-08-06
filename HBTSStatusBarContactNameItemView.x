#import "HBTSStatusBarContactNameItemView.h"

%subclass HBTSStatusBarContactNameItemView : UIStatusBarItemView

%property (nonatomic, retain) NSString *contactName;

- (UIImage *)contentsImage {
	return [self imageWithText:self.contactName];
}

- (NSTextAlignment)textAlignment {
	return NSTextAlignmentCenter;
}

- (UIStatusBarItemViewTextStyle)textStyle {
	return UIStatusBarItemViewTextStyleRegular;
}

- (void)dealloc {
	[self.contactName release];
	%orig;
}

%end
