#import "HBTSTwitterCell.h"

@implementation HBTSTwitterCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:[specifier.properties objectForKey:@"small"] && ((NSNumber *)[specifier.properties objectForKey:@"small"]).boolValue ? UITableViewCellStyleValue1 : UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		_user = [specifier.properties objectForKey:@"user"];

		NSBundle *bundle = [NSBundle bundleForClass:self.class];

		self.detailTextLabel.text = [@"@" stringByAppendingString:[specifier.properties objectForKey:@"user"]];
		self.target = self;
		self.action = @selector(cellTapped);
		//self.selectionStyle = UITableViewCellSelectionStyleBlue;
		self.accessoryView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"twitter" ofType:@"png"]] highlightedImage:[UIImage imageWithContentsOfFile:[bundle pathForResource:@"twitter_highlighted" ofType:@"png"]]];
	}

	return self;
}

- (void)cellTapped {
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
