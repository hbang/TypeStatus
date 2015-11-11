#import "HBTSCreditsListController.h"

@implementation HBTSCreditsListController

#pragma mark - PSListController

+ (NSString *)hb_specifierPlist {
	return @"Credits";
}

#pragma mark - Callbacks

- (void)openTranslations {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://www.hbang.ws/translations/"]];
}

@end
