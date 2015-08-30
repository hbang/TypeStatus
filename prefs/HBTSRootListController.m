#import "HBTSRootListController.h"
#import <Preferences/PSSpecifier.h>

@implementation HBTSRootListController

#pragma mark - Constants

+ (NSString *)hb_specifierPlist {
	return @"Root";
}

+ (NSString *)hb_shareText {
	return [[NSBundle bundleForClass:self.class] localizedStringForKey:@"SHARE_TEXT" value:nil table:@"Root"];
}

+ (NSURL *)hb_shareURL {
	return [NSURL URLWithString:@"https://typestatus.com/"];
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:83.f / 255.f green:215.f / 255.f blue:106.f / 255.f alpha:1];
}

@end
