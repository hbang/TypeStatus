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

	if (!self.iconName) {
		return nil;
	}

	UIImage *image = [UIImage imageNamed:[self.foregroundStyle expandedNameForImageName:self.iconName] inBundle:UIKitBundle];
	UIImage *tintedImage = [image _flatImageWithColor:self.foregroundStyle.tintColor];
	return [%c(_UILegibilityImageSet) imageFromImage:tintedImage withShadowImage:nil];
}

- (CGSize)intrinsicContentSize {
	return self.contentsImage.image.size;
}

- (void)updateContentsAndWidth {
	%orig;
	[self invalidateIntrinsicContentSize];
}

%end
