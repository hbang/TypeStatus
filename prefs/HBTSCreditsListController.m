#import "HBTSCreditsListController.h"

@implementation HBTSCreditsListController

#pragma mark - PSListController

- (instancetype)init {
	self = [super init];

	if (self) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Credits" target:self] retain];
	}

	return self;
}

@end
