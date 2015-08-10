#import "HBTSStatusBarForegroundView.h"
#import "HBTSStatusBarItem.h"
#import "HBTSStatusBarIconItemView.h"
#import "HBTSStatusBarAlertTypeItemView.h"
#import "HBTSStatusBarContactNameItemView.h"
#import <UIKit/UIStatusBar.h>

@interface HBTSStatusBarForegroundView ()

@property (nonatomic, retain) HBTSStatusBarItem *iconItem;
@property (nonatomic, retain) HBTSStatusBarItem *alertTypeItem;
@property (nonatomic, retain) HBTSStatusBarItem *contactNameItem;

@property (nonatomic, retain) HBTSStatusBarIconItemView *iconItemView;
@property (nonatomic, retain) HBTSStatusBarAlertTypeItemView *alertTypeItemView;
@property (nonatomic, retain) HBTSStatusBarContactNameItemView *contactNameItemView;

@end

%subclass HBTSStatusBarForegroundView : UIStatusBarForegroundView

%property (nonatomic, retain) UIStatusBarForegroundView *statusBarView;

%property (nonatomic, retain) HBTSStatusBarItem *iconItem;
%property (nonatomic, retain) HBTSStatusBarItem *alertTypeItem;
%property (nonatomic, retain) HBTSStatusBarItem *contactNameItem;

- (id)initWithFrame:(CGRect)frame foregroundStyle:(id)foregroundStyle usesVerticalLayout:(BOOL)usesVerticalLayout {
	self = %orig;

	if (self) {
		self.iconItem = [[%c(HBTSStatusBarItem) alloc] init];
		self.iconItem._typeStatus_viewClass = %c(HBTSStatusBarIconItemView);

		self.alertTypeItem = [[%c(HBTSStatusBarItem) alloc] init];
		self.alertTypeItem._typeStatus_viewClass = %c(HBTSStatusBarAlertTypeItemView);

		self.contactNameItem = [[%c(HBTSStatusBarItem) alloc] init];
		self.contactNameItem._typeStatus_viewClass = %c(HBTSStatusBarContactNameItemView);
	}

	return self;
}

- (NSDictionary *)_computeVisibleItemsPreservingHistory:(BOOL)preserveHistory {
	HBLogDebug(@"_computeVisibleItemsPreservingHistory:%i", preserveHistory);
	return @{
		@(UIStatusBarPositionCenter): @[ self.iconItem, self.alertTypeItem, self.contactNameItem ]
	};
}

%new - (void)setType:(HBTSStatusBarType)type contactName:(NSString *)contactName {
	NSNumber *boxedType = @(type);
	self.iconItemView.type = boxedType;
	self.alertTypeItemView.type = boxedType;

	self.contactNameItemView.contactName = contactName;
}

- (void)dealloc {
	[self.iconItem release];
	[self.alertTypeItem release];
	[self.contactNameItem release];
	[self.iconItemView release];
	[self.alertTypeItemView release];
	[self.contactNameItemView release];

	%orig;
}

%end
