#import "HBTSListController.h"
#include <notify.h>

@implementation HBTSListController
- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"TypeStatus" target:self] retain];
	}

	return _specifiers;
}

- (void)testTypingStatus {
	notify_post("ws.hbang.typestatus/TestTyping");
}

- (void)testReadStatus {
	notify_post("ws.hbang.typestatus/TestRead");
}
@end
