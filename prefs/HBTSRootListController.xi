#include "../Global.xm"

#import "HBTSRootListController.h"
#include <notify.h>

@implementation HBTSRootListController

#pragma mark - Constants

+ (NSString *)hb_shareText {
	return L18N(@"Check out #TypeStatus by HASHBANG Productions!");
}

+ (NSURL *)hb_shareURL {
	return [NSURL URLWithString:@"http://hbang.ws/typestatus"];
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:83.f / 255.f green:215.f / 255.f blue:106.f / 255.f alpha:1];
}

#pragma mark - PSListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return _specifiers;
}

#pragma mark - Callbacks

- (void)testTypingStatus {
	notify_post("ws.hbang.typestatus/TestTyping");
}

- (void)testReadStatus {
	notify_post("ws.hbang.typestatus/TestRead");
}

@end
