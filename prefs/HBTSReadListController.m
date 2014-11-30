#import "HBTSReadListController.h"
#import <Preferences/PSSpecifier.h>
#include <notify.h>

static NSString *const kHBTSReadIconIdentifier = @"ReadIcon";
static NSString *const kHBTSReadStatusIdentifier = @"ReadStatus";

@implementation HBTSReadListController {
	BOOL _isFlippingStuff;
}

#pragma mark - PSListController

- (instancetype)init {
	self = [super init];

	if (self) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Read" target:self] retain];
	}

	return self;
}

- (void)setPreferenceValue:(NSNumber *)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if (!_isFlippingStuff) {
		PSSpecifier *otherSpecifier = nil;

		if ([specifier.identifier isEqualToString:kHBTSReadIconIdentifier]) {
			otherSpecifier = [self specifierForID:kHBTSReadStatusIdentifier];
		} else if ([specifier.identifier isEqualToString:kHBTSReadStatusIdentifier]) {
			otherSpecifier = [self specifierForID:kHBTSReadIconIdentifier];
		}

		if (otherSpecifier && value.boolValue && ((NSNumber *)[self readPreferenceValue:otherSpecifier]).boolValue) {
			_isFlippingStuff = YES;
			[super setPreferenceValue:@(!value.boolValue) specifier:otherSpecifier];
			[self reloadSpecifier:otherSpecifier];
			_isFlippingStuff = NO;
		}
	}
}

#pragma mark - Callbacks

- (void)testReadStatus {
	notify_post("ws.hbang.typestatus/TestRead");
}

@end
