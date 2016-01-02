#import "HBTSStatusBarForegroundView.h"
#import "HBTSStatusBarIconItemView.h"
#import "HBTSStatusBarTitleItemView.h"
#import "HBTSStatusBarContentItemView.h"
#import <Cephei/UIView+CompactConstraint.h>
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
	self.translatesAutoresizingMaskIntoConstraints = NO;

	UIView *containerView = [[UIView alloc] init];
	containerView.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:containerView];

	self.containerView = containerView;

	self.iconItemView = [[%c(HBTSStatusBarIconItemView) alloc] initWithItem:[[[%c(UIStatusBarItem) alloc] init] autorelease] data:nil actions:kNilOptions style:self.foregroundStyle];
	self.iconItemView.translatesAutoresizingMaskIntoConstraints = NO;
	[containerView addSubview:self.iconItemView];

	self.titleItemView = [[%c(HBTSStatusBarTitleItemView) alloc] initWithItem:[[[%c(UIStatusBarItem) alloc] init] autorelease] data:nil actions:kNilOptions style:self.foregroundStyle];
	self.titleItemView.translatesAutoresizingMaskIntoConstraints = NO;
	[containerView addSubview:self.titleItemView];

	self.contentItemView = [[%c(HBTSStatusBarContentItemView) alloc] initWithItem:[[[%c(UIStatusBarItem) alloc] init] autorelease] data:nil actions:kNilOptions style:self.foregroundStyle];
	self.contentItemView.translatesAutoresizingMaskIntoConstraints = NO;
	[containerView addSubview:self.contentItemView];

	static BOOL isRTL;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		isRTL = [NSLocale characterDirectionForLanguage:[[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]] == NSLocaleLanguageDirectionRightToLeft;
	});

	NSDictionary <NSString *, UIView *> *views = @{
		@"self": self,
		@"containerView": containerView,
		@"iconItemView": self.iconItemView,
		@"titleItemView": self.titleItemView,
		@"contentItemView": self.contentItemView
	};

	NSDictionary <NSString *, NSNumber *> *metrics = @{
		@"outerMargin": @8.f,
		@"textMargin": @4.f,
		@"iconMargin": @6.f
	};

	[self hb_addCompactConstraints:@[
		@"containerView.centerX = self.centerX",
		@"containerView.top = self.top",
		@"containerView.bottom = self.bottom"
	] metrics:metrics views:views];

	[containerView hb_addCompactConstraints:@[
		@"iconItemView.top = containerView.top",
		@"iconItemView.bottom = containerView.bottom",

		@"titleItemView.top = containerView.top",
		@"titleItemView.bottom = containerView.bottom",

		@"contentItemView.top = containerView.top",
		@"contentItemView.bottom = containerView.bottom"
	] metrics:metrics views:views];

	NSString *constraints = isRTL
		? @"H:|-outerMargin-[contentItemView]-textMargin-[titleItemView]-iconMargin-[iconItemView]-outerMargin-|"
		: @"H:|-outerMargin-[iconItemView]-iconMargin-[titleItemView]-textMargin-[contentItemView]-outerMargin-|";

	[containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraints options:kNilOptions metrics:metrics views:views]];
}

- (void)layoutSubviews {
	[self.iconItemView updateContentsAndWidth];
	[self.titleItemView updateContentsAndWidth];
	[self.contentItemView updateContentsAndWidth];

	%orig;
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
