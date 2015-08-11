#import "HBTSStatusBarForegroundView.h"
#import "HBTSStatusBarIconItemView.h"
#import "HBTSStatusBarAlertTypeItemView.h"
#import "HBTSStatusBarContactNameItemView.h"

@interface HBTSStatusBarForegroundView ()

@property (nonatomic, retain) UIView *containerView;

@property (nonatomic, retain) HBTSStatusBarIconItemView *iconItemView;
@property (nonatomic, retain) HBTSStatusBarAlertTypeItemView *alertTypeItemView;
@property (nonatomic, retain) HBTSStatusBarContactNameItemView *contactNameItemView;

@end

%subclass HBTSStatusBarForegroundView : UIStatusBarForegroundView

%property (nonatomic, retain) UIStatusBarForegroundView *statusBarView;

%property (nonatomic, retain) UIView *containerView;

%property (nonatomic, retain) HBTSStatusBarIconItemView *iconItemView;
%property (nonatomic, retain) HBTSStatusBarAlertTypeItemView *alertTypeItemView;
%property (nonatomic, retain) HBTSStatusBarContactNameItemView *contactNameItemView;

- (id)initWithFrame:(CGRect)frame foregroundStyle:(id)foregroundStyle usesVerticalLayout:(BOOL)usesVerticalLayout {
	self = %orig;

	if (self) {
		UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width / 2, 0, 0, frame.size.height)];
		containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[self addSubview:containerView];

		self.containerView = containerView;

		self.iconItemView = [[%c(HBTSStatusBarIconItemView) alloc] initWithItem:[[%c(UIStatusBarItem) alloc] init] data:nil actions:kNilOptions style:foregroundStyle];
		[containerView addSubview:self.iconItemView];

		self.alertTypeItemView = [[%c(HBTSStatusBarAlertTypeItemView) alloc] initWithItem:[[%c(UIStatusBarItem) alloc] init] data:nil actions:kNilOptions style:foregroundStyle];
		[containerView addSubview:self.alertTypeItemView];

		self.contactNameItemView = [[%c(HBTSStatusBarContactNameItemView) alloc] initWithItem:[[%c(UIStatusBarItem) alloc] init] data:nil actions:kNilOptions style:foregroundStyle];
		[containerView addSubview:self.contactNameItemView];
	}

	return self;
}

- (void)layoutSubviews {
	%orig;

	CGRect iconFrame = self.iconItemView.frame;

	CGRect alertTypeFrame = self.alertTypeItemView.frame;
	alertTypeFrame.origin.x = iconFrame.size.width + 6.f;
	self.alertTypeItemView.frame = alertTypeFrame;

	CGRect contactNameFrame = self.contactNameItemView.frame;
	contactNameFrame.origin.x = alertTypeFrame.origin.x + alertTypeFrame.size.width + 4.f;
	self.contactNameItemView.frame = contactNameFrame;

	CGRect containerFrame = self.containerView.frame;
	containerFrame.size.width = contactNameFrame.origin.x + contactNameFrame.size.width;
	containerFrame.origin.x = MAX(0, (self.frame.size.width - containerFrame.size.width) / 2);
	self.containerView.frame = containerFrame;
}

%new - (void)setType:(HBTSStatusBarType)type contactName:(NSString *)contactName {
	NSNumber *boxedType = @(type);

	self.iconItemView.alertType = boxedType;
	[self.iconItemView updateContentsAndWidth];

	self.alertTypeItemView.alertType = boxedType;
	[self.alertTypeItemView updateContentsAndWidth];

	self.contactNameItemView.contactName = [contactName copy];
	[self.contactNameItemView updateContentsAndWidth];

	[self setNeedsLayout];
}

- (void)dealloc {
	[self.containerView release];
	[self.iconItemView release];
	[self.alertTypeItemView release];
	[self.contactNameItemView release];

	%orig;
}

%end
