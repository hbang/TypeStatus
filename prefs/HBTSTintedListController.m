#import "HBTSTintedListController.h"
#import <version.h>

#define IS_MODERN IS_IOS_OR_NEWER(iOS_7_0)
;

@implementation HBTSTintedListController

- (void)viewWillAppear:(BOOL)animated {
	if (IS_MODERN) {
		UIColor *tintColor = [UIColor colorWithRed:0 green:0.9019607843f blue:0.3960784314f alpha:1];
		self.view.tintColor = tintColor;
		self.navigationController.navigationBar.tintColor = tintColor;
	}
}

- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];

	if (IS_MODERN) {
		self.view.tintColor = nil;
		self.navigationController.navigationBar.tintColor = nil;
	}
}

@end
