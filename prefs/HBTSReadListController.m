#import "HBTSReadListController.h"
#include <notify.h>

@implementation HBTSReadListController

#pragma mark - PSListController

- (instancetype)init {
	self = [super init];

	if (self) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Read" target:self] retain];
	}

	return self;
}

#pragma mark - Callbacks

- (void)testReadStatus {
	notify_post("ws.hbang.typestatus/TestRead");
}

@end
