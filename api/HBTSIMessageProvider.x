#import "HBTSIMessageProvider.h"
#import "HBTSNotification.h"

@implementation HBTSIMessageProvider

- (instancetype)init {
	self = [super init];

	if (self) {
		self.appIdentifier = @"com.apple.MobileSMS";
		self.preferencesBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatus.bundle"];
		self.preferencesClass = @"HBTSAlertsListController";
	}

	return self;
}

@end
