#import "HBTSAlertsListController.h"
#import "HBTSPreferences.h"
#import <Preferences/PSSpecifier.h>
#include <notify.h>

@implementation HBTSAlertsListController {
	HBTSPreferences *_preferences;
}

+ (NSString *)hb_specifierPlist {
	return @"Alerts";
}

#pragma mark - UIViewController

- (instancetype)init {
	self = [super init];

	if (self) {
		_preferences = [%c(HBTSPreferences) sharedInstance];
	}

	return self;
}

- (void)viewDidLoad {
	[super viewDidLoad];
	[self _updateLibstatusbarState];
}

- (void)reloadSpecifiers {
	[super viewDidLoad];
	[self _updateLibstatusbarState];
}

- (void)_updateLibstatusbarState {
	if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/libstatusbar.dylib"]) {
		[self removeSpecifierID:@"NoLibstatusbar"];
		[self removeSpecifierID:@"NoLibstatusbarGroup"];
	}
}

#pragma mark - Callbacks

- (void)testTyping {
	notify_post("ws.hbang.typestatus/TestTyping");
}

- (void)testReadReceipt {
	notify_post("ws.hbang.typestatus/TestRead");
}

- (void)testSendingFile {
	notify_post("ws.hbang.typestatus/TestSendingFile");
}

- (void)openLibstatusbarPackage {
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"cydia://package/libstatusbar"]];
}

@end
