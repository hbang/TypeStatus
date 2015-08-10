#import "HBTSStatusBarContactNameItemView.h"
#import <UIKit/_UILegibilityImageSet.h>

%subclass HBTSStatusBarContactNameItemView : UIStatusBarItemView

%property (nonatomic, retain) NSString *contactName;

- (_UILegibilityImageSet *)contentsImage {
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
