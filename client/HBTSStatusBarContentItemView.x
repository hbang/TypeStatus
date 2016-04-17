#import "HBTSStatusBarContentItemView.h"
#import <UIKit/_UILegibilityImageSet.h>
#import <UIKit/UIImage+Private.h>
#import <UIKit/UIStatusBarForegroundStyleAttributes.h>

%subclass HBTSStatusBarContentItemView : UIStatusBarItemView

%property (nonatomic, retain) NSAttributedString *attributedString;

- (_UILegibilityImageSet *)contentsImage {
	NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine;

	// calculate the size of the rendered string
	CGRect textFrame = [self.attributedString boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:options context:nil];

	// work out how big the image will need to be
	CGRect actualFrame = textFrame;
	actualFrame.size.height = self.foregroundStyle.height;

	// move the text position accordingly
	textFrame.origin.y = (actualFrame.size.height - textFrame.size.height) / 2;

	// render the string into a context and get the UIImage
	UIGraphicsBeginImageContextWithOptions(actualFrame.size, NO, 0);
	[self.attributedString drawWithRect:textFrame options:options context:nil];
	UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();

	// return it as an image set
	return [%c(_UILegibilityImageSet) imageFromImage:image withShadowImage:nil];
}

- (NSTextAlignment)textAlignment {
	return NSTextAlignmentCenter;
}

- (CGSize)intrinsicContentSize {
	return self.contentsImage.image.size;
}

- (void)updateContentsAndWidth {
	%orig;
	[self invalidateIntrinsicContentSize];
}

%end
