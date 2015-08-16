#import "HBTSAlertTypesListController.h"
#import <Preferences/PSSpecifier.h>
#include <notify.h>

@implementation HBTSAlertTypesListController

+ (NSString *)hb_specifierPlist {
	return @"AlertTypes";
}

#pragma mark - Callbacks

- (void)testTyping {
	notify_post("ws.hbang.typestatus/TestTyping");
}

- (void)testReadReceipt {
	notify_post("ws.hbang.typestatus/TestRead");
}

@end
