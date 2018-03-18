#import "HBTSStatusBarForegroundView.h"
#import "HBTSStatusBarIconItemView.h"
#import "HBTSStatusBarContentItemView.h"
#import <Cephei/UIView+CompactConstraint.h>
#import <UIKit/UIStatusBarForegroundStyleAttributes.h>
#import <UIKit/UIStatusBarItem.h>
#import <version.h>

@interface HBTSStatusBarForegroundView ()

- (void)_typeStatus_init;

@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, retain) HBTSStatusBarIconItemView *iconItemView;
@property (nonatomic, retain) HBTSStatusBarContentItemView *contentItemView;

@end

%subclass HBTSStatusBarForegroundView : UIStatusBarForegroundView

%property (nonatomic, retain) UIStatusBarForegroundView *statusBarView;

%property (nonatomic, retain) UIView *containerView;
%property (nonatomic, retain) HBTSStatusBarIconItemView *iconItemView;
%property (nonatomic, retain) HBTSStatusBarContentItemView *contentItemView;

%group CarPlay

- (id)initWithFrame:(CGRect)frame foregroundStyle:(id)foregroundStyle usesVerticalLayout:(BOOL)usesVerticalLayout {
	self = %orig;

	if (self) {
		if (!usesVerticalLayout) {
			[self _typeStatus_init];
		}
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
	self.containerView = [[UIView alloc] init];
	self.containerView.translatesAutoresizingMaskIntoConstraints = NO;
	[self addSubview:self.containerView];

	// these UIStatusBarItems leak, but there’s not much we can do about that
	self.iconItemView = [[%c(HBTSStatusBarIconItemView) alloc] initWithItem:[[%c(UIStatusBarItem) alloc] init] data:nil actions:kNilOptions style:self.foregroundStyle];
	self.iconItemView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.containerView addSubview:self.iconItemView];

	self.contentItemView = [[%c(HBTSStatusBarContentItemView) alloc] initWithItem:[[%c(UIStatusBarItem) alloc] init] data:nil actions:kNilOptions style:self.foregroundStyle];
	self.contentItemView.translatesAutoresizingMaskIntoConstraints = NO;
	[self.containerView addSubview:self.contentItemView];

	NSDictionary <NSString *, UIView *> *views = @{
		@"self": self,
		@"containerView": self.containerView,
		@"iconItemView": self.iconItemView,
		@"contentItemView": self.contentItemView
	};

	NSDictionary <NSString *, NSNumber *> *metrics = @{
		@"outerMargin": @8.f,
		@"iconMargin": @6.f
	};

	[self hb_addCompactConstraints:@[
		@"containerView.centerX = self.centerX",
		@"containerView.top = self.top",
		@"containerView.bottom = self.bottom"
	] metrics:metrics views:views];

	[self.containerView hb_addCompactConstraints:@[
		@"iconItemView.top = containerView.top",
		@"iconItemView.bottom = containerView.bottom",

		@"contentItemView.top = containerView.top",
		@"contentItemView.bottom = containerView.bottom"
	] metrics:metrics views:views];

	[self.containerView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-outerMargin-[iconItemView]-iconMargin-[contentItemView]-outerMargin-|" options:kNilOptions metrics:metrics views:views]];
}

- (void)layoutSubviews {
	[self.iconItemView updateContentsAndWidth];
	[self.contentItemView updateContentsAndWidth];

	%orig;
}

- (CGSize)sizeThatFits:(CGSize)size {
	if (IS_IOS_OR_NEWER(iOS_8_0)) {
		return [self.containerView systemLayoutSizeFittingSize:size withHorizontalFittingPriority:UILayoutPriorityDefaultLow verticalFittingPriority:UILayoutPriorityDefaultLow];
	} else {
		return %orig;
	}
}

%new - (void)setIconName:(NSString *)iconName text:(NSString *)text boldRange:(NSRange)boldRange {
	UIFont *font = [self.foregroundStyle textFontForStyle:UIStatusBarItemViewTextStyleRegular];
	UIFont *boldFont = [self.foregroundStyle textFontForStyle:UIStatusBarItemViewTextStyleBold];

	if (!font || !boldFont) {
		HBLogError(@"The fonts we are trying to use are not valid.");
		return;
	}

	self.iconItemView.iconName = [iconName copy];

	// init an attributed string with the standard config
	NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:@{
		NSFontAttributeName: font,
		NSForegroundColorAttributeName: self.foregroundStyle.tintColor
	}];

	// as long as boldRange isn’t {0,0}, set the bold attributes
	if (boldRange.location + boldRange.length != 0) {
		[attributedString addAttributes:@{
			NSFontAttributeName: boldFont
		} range:boldRange];
	}

	self.contentItemView.attributedString = attributedString;

	[self setNeedsLayout];
}

- (void)dealloc {
	[self.containerView release];
	[self.iconItemView release];
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
