#import "HBTSReadListController.h"
#import <Preferences/PSSpecifier.h>
#include <notify.h>

@implementation HBTSReadListController

#pragma mark - PSListController

+ (NSString *)hb_specifierPlist {
	return @"Read";
}

#pragma mark - Callbacks

- (void)testReadStatus {
	notify_post("ws.hbang.typestatus/TestRead");
}

@end
