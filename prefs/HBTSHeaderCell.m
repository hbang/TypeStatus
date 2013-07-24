#import "HBTSHeaderCell.h"

#define kHBTSHeaderCellFontSize 25.f

@implementation HBTSHeaderCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		self.backgroundView = [[[UIView alloc] init] autorelease];

		UIView *containerView = [[[UIView alloc] init] autorelease];
		containerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[self.contentView addSubview:containerView];

		UIImageView *imageView = [[[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[[NSBundle bundleForClass:self.class] pathForResource:@"icon" ofType:@"png"]]] autorelease];
		[containerView addSubview:imageView];

		UILabel *typeLabel = [[[UILabel alloc] init] autorelease];
		typeLabel.text = @"Type";
		typeLabel.backgroundColor = [UIColor clearColor];
		typeLabel.font = [UIFont boldSystemFontOfSize:kHBTSHeaderCellFontSize];
		[containerView addSubview:typeLabel];

		UILabel *statusLabel = [[[UILabel alloc] init] autorelease];
		statusLabel.text = @"Status 1.1.1";
		statusLabel.backgroundColor = [UIColor clearColor];
		statusLabel.font = [UIFont systemFontOfSize:kHBTSHeaderCellFontSize];
		[containerView addSubview:statusLabel];

		typeLabel.frame = CGRectMake(imageView.image.size.width + 10.f, 1.f, [typeLabel.text sizeWithFont:typeLabel.font].width, imageView.image.size.height);
		statusLabel.frame = CGRectMake(typeLabel.frame.origin.x + typeLabel.frame.size.width, typeLabel.frame.origin.y, [statusLabel.text sizeWithFont:statusLabel.font].width, imageView.image.size.height);
		containerView.frame = CGRectMake(0, typeLabel.frame.origin.y, statusLabel.frame.origin.x + statusLabel.frame.size.width, imageView.image.size.height);
		containerView.center = CGPointMake(self.contentView.frame.size.width / 2.f, containerView.center.y);
		imageView.center = CGPointMake(imageView.center.x, containerView.frame.size.height / 2.f)
	}

	return self;
}

- (float)preferredHeightForWidth:(float)width {
	return [@"" sizeWithFont:[UIFont systemFontOfSize:kHBTSHeaderCellFontSize]].height;
}
@end
