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
	return [UIColor colorWithRed:0 green:0.9019607843f blue:0.3960784314f alpha:1];
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
