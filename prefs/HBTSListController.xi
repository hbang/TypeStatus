#include "../Global.xm"

#import "HBTSListController.h"
#include <notify.h>

@implementation HBTSListController

#pragma mark - Constants

+ (NSString *)hb_shareText {
	return L18N(@"Check out #TypeStatus by HASHBANG Productions!");
}

+ (NSURL *)hb_shareURL {
	return [NSURL URLWithString:@"http://hbang.ws/typestatus"];
}

#pragma mark - PSListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"TypeStatus" target:self] retain];
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
