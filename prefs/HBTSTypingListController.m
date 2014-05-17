#import "HBTSTypingListController.h"
#import <Preferences/PSSpecifier.h>
#include <notify.h>

static NSString *const kHBTSTypingIconIdentifier = @"TypingIcon";
static NSString *const kHBTSTypingStatusIdentifier = @"TypingStatus";

@implementation HBTSTypingListController {
	BOOL _isFlippingStuff;
}

#pragma mark - PSListController

- (instancetype)init {
	self = [super init];

	if (self) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Typing" target:self] retain];
	}

	return self;
}

- (void)setPreferenceValue:(NSNumber *)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if (!_isFlippingStuff) {
		PSSpecifier *otherSpecifier = nil;

		if ([specifier.identifier isEqualToString:kHBTSTypingIconIdentifier]) {
			otherSpecifier = [self specifierForID:kHBTSTypingStatusIdentifier];
		} else if ([specifier.identifier isEqualToString:kHBTSTypingStatusIdentifier]) {
			otherSpecifier = [self specifierForID:kHBTSTypingIconIdentifier];
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

- (void)testTypingStatus {
	notify_post("ws.hbang.typestatus/TestTyping");
}

@end
