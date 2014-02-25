#include "../Global.xm"

#import "HBTSRootListController.h"
#import <Preferences/PSSpecifier.h>
#include <notify.h>

static NSString *const kHBTSTypingIconIdentifier = @"TypingIcon";
static NSString *const kHBTSTypingStatusIdentifier = @"TypingStatus";

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
		_specifiers = [[self loadSpecifiersFromPlistName:@"Root" target:self] retain];
	}

	return self;
}

- (void)setPreferenceValue:(id)value specifier:(PSSpecifier *)specifier {
	PSSpecifier *otherSpecifier = nil;

	if ([specifier.identifier isEqualToString:kHBTSTypingIconIdentifier]) {
		otherSpecifier = [self specifierForID:kHBTSTypingStatusIdentifier];
	} else if ([specifier.identifier isEqualToString:kHBTSTypingStatusIdentifier]) {
		otherSpecifier = [self specifierForID:kHBTSTypingIconIdentifier];
	}

	if (otherSpecifier && ((NSNumber *)[self readPreferenceValue:otherSpecifier]).boolValue) {
		[self setPreferenceValue:@NO specifier:otherSpecifier];
		[self reloadSpecifier:otherSpecifier];
	}

	[super setPreferenceValue:value specifier:specifier];
}

#pragma mark - Callbacks

- (void)testTypingStatus {
	notify_post("ws.hbang.typestatus/TestTyping");
}

- (void)testReadStatus {
	notify_post("ws.hbang.typestatus/TestRead");
}

@end
