#import "HBTSTwitterCell.h"
#import <QuartzCore/QuartzCore.h>

@implementation HBTSTwitterCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		self.backgroundView = [[UIView alloc] init];
		self.textLabel.hidden = YES;

		_user = [specifier.properties objectForKey:@"user"];

		_twitterButton = [[UIButton alloc] init];

		[_twitterButton addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];

		[_twitterButton setTitle:[specifier.properties objectForKey:@"label"] forState:UIControlStateNormal];
		[_twitterButton setTitleColor:[UIColor colorWithRed:76.f / 255.f green:86.f / 255.f blue:108.f / 255.f alpha:1] forState:UIControlStateNormal];
		[_twitterButton setTitleColor:[UIColor colorWithRed:56.f / 255.f green:66.f / 255.f blue:88.f / 255.f alpha:1] forState:UIControlStateHighlighted];
		[_twitterButton setTitleShadowColor:[UIColor colorWithWhite:1 alpha:0.5f] forState:UIControlStateNormal];
		_twitterButton.titleLabel.textAlignment = UITextAlignmentCenter;
		_twitterButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
		_twitterButton.titleLabel.shadowOffset = CGSizeMake(0, 1);
		_twitterButton.backgroundColor = [UIColor clearColor];
		_twitterButton.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		[self.contentView addSubview:_twitterButton];

		_underlineView = [[UIView alloc] initWithFrame:CGRectMake(_twitterButton.titleLabel.frame.origin.x, _twitterButton.titleLabel.frame.size.height - 1.f, _twitterButton.titleLabel.frame.size.width, 1.f)];
		_underlineView.backgroundColor = [_twitterButton titleColorForState:UIControlStateNormal];
		_underlineView.layer.shadowColor = [UIColor colorWithWhite:1 alpha:0.5f].CGColor;
		_underlineView.layer.shadowOffset = CGSizeMake(0, 1);
		_underlineView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[_twitterButton addSubview:_underlineView];
	}

	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	CGRect buttonFrame = _twitterButton.frame;
	buttonFrame.size.width = self.contentView.frame.size.width;
	buttonFrame.size.height = self.contentView.frame.size.height;
	_twitterButton.frame = buttonFrame;

	CGSize textSize = [_twitterButton.titleLabel.text sizeWithFont:_twitterButton.titleLabel.font];

	_underlineView.center = _twitterButton.center;

	CGRect underlineFrame = _underlineView.frame;
	underlineFrame.size.width = textSize.width;
	underlineFrame.origin.y += textSize.height / 2.f;
	_underlineView.frame = underlineFrame;

	_underlineView.center = CGPointMake(_twitterButton.center.x, _underlineView.center.y);
}

- (void)buttonTapped {
	if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:_user]]];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitterrific:///profile?screen_name=" stringByAppendingString:_user]]];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetings:///user?screen_name=" stringByAppendingString:_user]]];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:_user]]];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:_user]]];
	}
}

- (float)preferredHeightForWidth:(float)width {
	return [_twitterButton.titleLabel.text sizeWithFont:_twitterButton.titleLabel.font].height + 1.f;
}
@end
