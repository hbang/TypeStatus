#import "HBTSTypingListController.h"
#import <Preferences/PSSpecifier.h>
#include <notify.h>

static NSString *const kHBTSIconIdentifier = @"Icon";
static NSString *const kHBTSStatusIdentifier = @"Status";

@implementation HBTSTypingListController {
	BOOL _isFlippingStuff;
}

+ (NSString *)hb_specifierPlist {
	return @"Typing";
}

#pragma mark - PSListController

- (void)setPreferenceValue:(NSNumber *)value specifier:(PSSpecifier *)specifier {
	[super setPreferenceValue:value specifier:specifier];

	if (!_isFlippingStuff) {
		PSSpecifier *otherSpecifier = nil;

		if ([specifier.identifier isEqualToString:kHBTSIconIdentifier]) {
			otherSpecifier = [self specifierForID:kHBTSStatusIdentifier];
		} else if ([specifier.identifier isEqualToString:kHBTSStatusIdentifier]) {
			otherSpecifier = [self specifierForID:kHBTSIconIdentifier];
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
