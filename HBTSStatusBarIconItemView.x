#import "HBTSStatusBarIconItemView.h"

%subclass HBTSStatusBarIconItemView : UIStatusBarItemView

%property (nonatomic, retain) NSNumber *type;

- (UIImage *)contentsImage {
	HBTSStatusBarType type = (HBTSStatusBarType)self.type.unsignedIntegerValue;

	switch (type) {
		case HBTSStatusBarTypeTyping:
			return [self imageWithShadowNamed:@"TypeStatus"];
			break;

		case HBTSStatusBarTypeRead:
			return [self imageWithShadowNamed:@"TypeStatusRead"];
			break;

		case HBTSStatusBarTypeTypingEnded:
			return nil;
			break;
	}
}

- (void)dealloc {
	[self.type release];
	%orig;
}

%end
