#include "../Global.xm"

#import "HBTSRootListController.h"
#import <Preferences/PSSpecifier.h>
#import <version.h>

static NSString *const kHBTSOverlayDurationIdentifier = @"OverlayDuration";
static NSString *const kHBTSOverlayDurationLegacyIdentifier = @"OverlayDurationLegacy";

@implementation HBTSRootListController

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

@end
