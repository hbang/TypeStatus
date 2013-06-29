#import "HBTSTwitterCell.h"
#import <UIKit/UIColor+Private.h>

@implementation HBTSTwitterCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:[specifier.properties objectForKey:@"big"] && ((NSNumber *)[specifier.properties objectForKey:@"big"]).boolValue ? UITableViewCellStyleSubtitle : UITableViewCellStyleValue1 reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		_user = [specifier.properties objectForKey:@"user"];

		NSBundle *bundle = [NSBundle bundleForClass:self.class];

		_defaultImage = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:@"twitter" ofType:@"png"]];
		_highlightedImage = [[UIImage alloc] initWithContentsOfFile:[bundle pathForResource:@"twitter_selected" ofType:@"png"]];

		self.detailTextLabel.text = [@"@" stringByAppendingString:[specifier.properties objectForKey:@"user"]];
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
		self.accessoryView = [[UIImageView alloc] initWithImage:_defaultImage];
	}

	return self;
}

- (void)setSelectionStyle:(UITableViewCellSelectionStyle)style {
	[super setSelectionStyle:UITableViewCellSelectionStyleBlue];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
	[super setHighlighted:highlighted animated:animated];

	((UIImageView *)self.accessoryView).image = highlighted ? _highlightedImage : _defaultImage;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
	if (!selected) {
		[super setSelected:selected animated:animated];
		return;
	}

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
@end
