#import "HBTSStatusBarIconItemView.h"
#import <UIKit/_UILegibilityImageSet.h>
#import <UIKit/UIImage+Private.h>
#import <UIKit/UIStatusBarForegroundStyleAttributes.h>

%subclass HBTSStatusBarIconItemView : UIStatusBarItemView

%property (nonatomic, retain) NSString *iconName;

- (_UILegibilityImageSet *)contentsImage {
	static NSBundle *UIKitBundle;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		UIKitBundle = [NSBundle bundleForClass:UIView.class];
	});

	UIImage *image = [UIImage imageNamed:[self.foregroundStyle expandedNameForImageName:self.iconName] inBundle:UIKitBundle];
	return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:nil];
}

- (void)dealloc {
	[self.iconName release];
	%orig;
}

%end
