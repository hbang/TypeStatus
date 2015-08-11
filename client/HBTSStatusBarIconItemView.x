#import "HBTSStatusBarIconItemView.h"
#import <UIKit/_UILegibilityImageSet.h>
#import <UIKit/UIStatusBarForegroundStyleAttributes.h>
#import <UIKit/UIImage+Private.h>

%subclass HBTSStatusBarIconItemView : UIStatusBarItemView

%property (nonatomic, retain) NSNumber *alertType;

- (_UILegibilityImageSet *)contentsImage {
	static NSBundle *UIKitBundle;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		UIKitBundle = [NSBundle bundleForClass:UIView.class];
	});

	HBTSStatusBarType type = (HBTSStatusBarType)self.alertType.unsignedIntegerValue;
	NSString *name = nil;

	switch (type) {
		case HBTSStatusBarTypeTyping:
			name = @"TypeStatus";
			break;

		case HBTSStatusBarTypeRead:
			name = @"TypeStatusRead";
			break;

		case HBTSStatusBarTypeTypingEnded:
			break;
	}

	UIImage *image = [UIImage imageNamed:[self.foregroundStyle expandedNameForImageName:name] inBundle:UIKitBundle];
	return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:nil];
}

- (void)dealloc {
	[self.alertType release];
	%orig;
}

%end
