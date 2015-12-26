#import "HBTSStatusBarForegroundView.h"
#import "HBTSStatusBarIconItemView.h"
#import "HBTSStatusBarTitleItemView.h"
#import "HBTSStatusBarContentItemView.h"
#import <UIKit/UIStatusBarForegroundStyleAttributes.h>
#import <version.h>

@interface HBTSStatusBarForegroundView ()

- (void)_typeStatus_init;

@property (nonatomic, retain) UIView *containerView;

@property (nonatomic, retain) HBTSStatusBarIconItemView *iconItemView;
@property (nonatomic, retain) HBTSStatusBarTitleItemView *titleItemView;
@property (nonatomic, retain) HBTSStatusBarContentItemView *contentItemView;

@end

%subclass HBTSStatusBarForegroundView : UIStatusBarForegroundView

%property (nonatomic, retain) UIStatusBarForegroundView *statusBarView;

%property (nonatomic, retain) UIView *containerView;

%property (nonatomic, retain) HBTSStatusBarIconItemView *iconItemView;
%property (nonatomic, retain) HBTSStatusBarTitleItemView *titleItemView;
%property (nonatomic, retain) HBTSStatusBarContentItemView *contentItemView;

%group CarPlay

- (id)initWithFrame:(CGRect)frame foregroundStyle:(id)foregroundStyle usesVerticalLayout:(BOOL)usesVerticalLayout {
	self = %orig;

	if (self) {
		[self _typeStatus_init];
	}

	return self;
}

%end

%group Ive

- (id)initWithFrame:(CGRect)frame foregroundStyle:(id)foregroundStyle {
	self = %orig;

	if (self) {
		[self _typeStatus_init];
	}

	return self;
}

%end

%new - (void)_typeStatus_init {
	UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(self.frame.size.width / 2, 0, 0, self.frame.size.height)];
	containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
	[self addSubview:containerView];

	self.containerView = containerView;

	self.iconItemView = [[%c(HBTSStatusBarIconItemView) alloc] initWithItem:[[[%c(UIStatusBarItem) alloc] init] autorelease] data:nil actions:kNilOptions style:self.foregroundStyle];
	[containerView addSubview:self.iconItemView];

	self.titleItemView = [[%c(HBTSStatusBarTitleItemView) alloc] initWithItem:[[[%c(UIStatusBarItem) alloc] init] autorelease] data:nil actions:kNilOptions style:self.foregroundStyle];
	[containerView addSubview:self.titleItemView];

	self.contentItemView = [[%c(HBTSStatusBarContentItemView) alloc] initWithItem:[[[%c(UIStatusBarItem) alloc] init] autorelease] data:nil actions:kNilOptions style:self.foregroundStyle];
	[containerView addSubview:self.contentItemView];
}

- (void)layoutSubviews {
	%orig;

	[self.iconItemView updateContentsAndWidth];
	[self.titleItemView updateContentsAndWidth];
	[self.contentItemView updateContentsAndWidth];

	CGRect iconFrame = self.iconItemView.frame;

	CGRect titleFrame = self.titleItemView.frame;
	titleFrame.origin.x = iconFrame.size.width + 6.f;
	self.titleItemView.frame = titleFrame;

	CGRect contentFrame = self.contentItemView.frame;
	contentFrame.origin.x = titleFrame.origin.x + titleFrame.size.width + 4.f;
	self.contentItemView.frame = contentFrame;

	CGRect containerFrame = self.containerView.frame;
	containerFrame.size.width = contentFrame.origin.x + contentFrame.size.width;
	containerFrame.origin.x = MAX(0, ceil((self.frame.size.width - containerFrame.size.width) / 2));
	self.containerView.frame = containerFrame;
}

%new - (void)setIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content {
	self.iconItemView.iconName = [iconName copy];
	self.titleItemView.text = [title copy];
	self.contentItemView.text = [content copy];

	[self setNeedsLayout];
}

- (void)dealloc {
	[self.containerView release];
	[self.iconItemView release];
	[self.titleItemView release];
	[self.contentItemView release];

	%orig;
}

%end

#pragma mark - Constructor

%ctor {
	%init;

	if (IS_IOS_OR_NEWER(iOS_7_1)) {
		%init(CarPlay);
	} else {
		%init(Ive);
	}
}
