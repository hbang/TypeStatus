#import "HBTSAboutListController.h"

@implementation HBTSAboutListController

#pragma mark - PSListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"About" target:self] retain];
	}

	return _specifiers;
}

#pragma mark - Callbacks

- (void)openWebsite {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://hbang.ws"]];
}

- (void)openDonate {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://hbang.ws/donate"]];
}

@end
