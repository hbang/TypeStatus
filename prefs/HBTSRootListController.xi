#include "../Global.xm"

#import "HBTSRootListController.h"
#import <Preferences/PSSpecifier.h>
#import <version.h>
#include <notify.h>

static NSString *const kHBTSTypingIconIdentifier = @"TypingIcon";
static NSString *const kHBTSTypingStatusIdentifier = @"TypingStatus";
static NSString *const kHBTSOverlayDurationIdentifier = @"OverlayDuration";
static NSString *const kHBTSOverlayDurationLegacyIdentifier = @"OverlayDurationLegacy";

@implementation HBTSRootListController {
	BOOL _isFlippingStuff;
}

#pragma mark - Constants

+ (NSString *)hb_shareText {
	return L18N(@"Check out #TypeStatus by HASHBANG Productions!");
}

+ (NSURL *)hb_shareURL {
	return [NSURL URLWithString:@"http://hbang.ws/typestatus"];
}

+ (UIColor *)hb_tintColor {
	return [UIColor colorWithRed:83.f / 255.f green:215.f / 255.f blue:106.f / 255.f alpha:1];
}

#pragma mark - PSListController

- (instancetype)init {
	self = [super init];

	if (self) {
		NSArray *oldSpecifiers = [self loadSpecifiersFromPlistName:@"Root" target:self];
		NSMutableArray *specifiers = [[NSMutableArray alloc] init];

		for (PSSpecifier *specifier in oldSpecifiers) {
			if (([specifier.identifier isEqualToString:kHBTSOverlayDurationIdentifier] && IS_IOS_OR_OLDER(iOS_5_1))
				|| ([specifier.identifier isEqualToString:kHBTSOverlayDurationLegacyIdentifier] && IS_IOS_OR_NEWER(iOS_6_0))) {
				continue;
			}

			[specifiers addObject:specifier];
		}

		_specifiers = specifiers;
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

- (void)testReadStatus {
	notify_post("ws.hbang.typestatus/TestRead");
}

@end
