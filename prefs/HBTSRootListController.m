#import "HBTSRootListController.h"
#import <CepheiPrefs/HBAppearanceSettings.h>
#import <Preferences/PSSpecifier.h>

@implementation HBTSRootListController

#pragma mark - Constants

+ (NSString *)hb_specifierPlist {
	return @"Root";
}

+ (NSString *)hb_shareText {
	return [NSString stringWithFormat:NSLocalizedStringFromTableInBundle(@"SHARE_TEXT", @"Root", [NSBundle bundleForClass:self.class], @"Default text for sharing the tweak. %@ is the device type (ie, iPhone)."), [UIDevice currentDevice].localizedModel];
}

+ (NSURL *)hb_shareURL {
	return [NSURL URLWithString:@"https://typestatus.com/"];
}

#pragma mark - UIViewController

- (instancetype)init {
	self = [super init];

	if (self) {
		HBAppearanceSettings *appearanceSettings = [[HBAppearanceSettings alloc] init];
		appearanceSettings.tintColor = [UIColor colorWithRed:83.f / 255.f green:215.f / 255.f blue:106.f / 255.f alpha:1];
		self.hb_appearanceSettings = appearanceSettings;
	}

	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self _removeTypeStatusPlusIfNeeded];
}

- (void)reloadSpecifiers {
	[super reloadSpecifiers];
	[self _removeTypeStatusPlusIfNeeded];
}

- (void)_removeTypeStatusPlusIfNeeded {
	NSBundle *plusBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatusPlus.bundle"];

	if (!plusBundle.executableURL) {
		[self removeSpecifierID:@"TypeStatusPlus"];
		[self removeSpecifierID:@"TypeStatusPlusGroup"];
	}
}

@end
