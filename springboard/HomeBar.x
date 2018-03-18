#import "../client/HBTSStatusBarForegroundView.h"
#import "HBTSStatusBarAlertController.h"
#import "HBTSPreferences.h"
#import <SpringBoard/SBHomeGrabberView.h>
#import <MaterialKit/MTLumaDodgePillView.h>
#import <UIKit/UIStatusBarAnimationParameters.h>
#import <UIKit/UIStatusBarForegroundStyleAttributes.h>

static CGFloat const kHBTSExpandedHomeGrabberWidth = 200.f;
static CGFloat const kHBTSExpandedHomeGrabberHeight = 20.f;

#pragma mark - SBHomeGrabberView category

@interface SBHomeGrabberView (TypeStatus)

@property (nonatomic, retain) UIView *_typeStatus_backgroundContainerView;
@property (nonatomic, retain) MTLumaDodgePillView *_typeStatus_backgroundView;
@property (nonatomic, retain) HBTSStatusBarForegroundView *_typeStatus_foregroundView;

@property BOOL _typeStatus_isAnimating;
@property BOOL _typeStatus_isVisible;

- (void)_typeStatus_updateForegroundViewForPillStyle:(MTLumaDodgePillStyle)style;

- (CGRect)_typeStatus_pillViewFrame;
- (CGRect)_typeStatus_foregroundViewFrame;

@end

#pragma mark - Hooks

%hook SBHomeGrabberView

%property (nonatomic, retain) UIView *_typeStatus_backgroundContainerView;
%property (nonatomic, retain) MTLumaDodgePillView *_typeStatus_backgroundView;
%property (nonatomic, retain) HBTSStatusBarForegroundView *_typeStatus_foregroundView;

%property (assign) BOOL _typeStatus_isAnimating;
%property (assign) BOOL _typeStatus_isVisible;

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
	self = %orig;

	if (self) {
		[[%c(HBTSStatusBarAlertController) sharedInstance] addHomeGrabber:self];

		UIView *typeStatusView = [[UIView alloc] initWithFrame:self.bounds];
		typeStatusView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self addSubview:typeStatusView];

		UIView *backgroundContainerView = [[UIView alloc] init];
		backgroundContainerView.alpha = 0;
		backgroundContainerView.clipsToBounds = YES;
		[self addSubview:backgroundContainerView];
		self._typeStatus_backgroundContainerView = backgroundContainerView;

		MTLumaDodgePillView *backgroundView = [[%c(MTLumaDodgePillView) alloc] initWithFrame:CGRectZero];
		backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[backgroundContainerView addSubview:backgroundView];
		self._typeStatus_backgroundView = backgroundView;

		[self _typeStatus_updateForegroundViewForPillStyle:MTLumaDodgePillStyleNone];
	}

	return self;
}

%new - (void)_typeStatus_updateForegroundViewForPillStyle:(MTLumaDodgePillStyle)style {
	// we have to throw away the whole foreground view just to change its color, because ugh, whatever
	UIColor *tintColor = nil;

	switch (style) {
		case MTLumaDodgePillStyleNone:
		case MTLumaDodgePillStyleThin:
		case MTLumaDodgePillStyleBlack:
			tintColor = [UIColor whiteColor];
			break;

		case MTLumaDodgePillStyleGray:
		case MTLumaDodgePillStyleWhite:
			tintColor = [UIColor blackColor];
			break;
	}

	CGRect frame = self._typeStatus_foregroundView ? self._typeStatus_foregroundView.frame : CGRectMake(0, 0, kHBTSExpandedHomeGrabberWidth, kHBTSExpandedHomeGrabberHeight);
	UIStatusBarForegroundStyleAttributes *foregroundStyle = [[%c(UIStatusBarForegroundStyleAttributes) alloc] initWithHeight:kHBTSExpandedHomeGrabberHeight legibilityStyle:0 tintColor:tintColor hasBusyBackground:NO];

	HBTSStatusBarForegroundView *foregroundView = [[%c(HBTSStatusBarForegroundView) alloc] initWithFrame:frame foregroundStyle:foregroundStyle usesVerticalLayout:NO];

	if (self._typeStatus_foregroundView) {
		[self._typeStatus_foregroundView removeFromSuperview];
	}

	[self addSubview:foregroundView];
	self._typeStatus_foregroundView = foregroundView;

	[[%c(HBTSStatusBarAlertController) sharedInstance] displayCurrentAlertInHomeGrabber:self animated:NO];
}

%new - (void)_typeStatus_changeToDirection:(BOOL)direction animated:(BOOL)animated {
	// words you will be confused by while reading this code:
	// • pill view: the regular home bar displayed by the system. we just show/hide this, nothing else
	// • background view: an almost-identical clone of the pill view, used for our own needs,
	//   including animations
	// • foreground view: the typestatus notification icon and text we all know and love. this is just
	//   faded in and out
	// YES direction is show, NO is hide
	HBTSStatusBarForegroundView *foregroundView = self._typeStatus_foregroundView;
	UIView *backgroundView = self._typeStatus_backgroundContainerView;
	MTLumaDodgePillView *pillView = [self valueForKey:@"_pillView"];

	BOOL reduceMotion = ((HBTSPreferences *)[%c(HBTSPreferences) sharedInstance]).reduceMotion;

	if (direction && self._typeStatus_isVisible) {
		// if animated, use the same animation parameters used in status bar show/hide animations. else
		// use nil, which will just call the method instantly
		UIStatusBarHideAnimationParameters *animationParameters = animated && !reduceMotion ? [[%c(UIStatusBarHideAnimationParameters) alloc] initWithDefaultParameters] : nil;

		[foregroundView layoutSubviews];
		foregroundView.frame = [self _typeStatus_foregroundViewFrame];

		[%c(UIStatusBarAnimationParameters) animateWithParameters:(UIStatusBarAnimationParameters *)animationParameters animations:^{
			// update the frame
			backgroundView.frame = foregroundView.frame;
		} completion:nil];
	}

	// if we’re currently animating, or the direction matches the current visibility
	if (self._typeStatus_isAnimating || self._typeStatus_isVisible == direction) {
		return;
	}

	// set our state based on the direction and whether we’re animating
	self._typeStatus_isVisible = direction;
	self._typeStatus_isAnimating = animated;

	// regardless of the animation, the foreground view fades. set the initial state of that
	foregroundView.alpha = direction ? 0 : 1;

	if (reduceMotion) {
		// if fading or no-animation, ensure we have our initial state
		backgroundView.alpha = direction ? 0 : 1;
		pillView.alpha = direction ? 1 : 0;
	} else {
		// if showing, set the initial frame of the background view to the frame of the pill view, so we
		// can seamlessly switch between them
		if (direction) {
			backgroundView.frame = pillView.frame;
		}

		// force our view to visible, and the pill view to hidden
		backgroundView.alpha = 1;
		pillView.alpha = 0;
	}

	// if showing, expand our view so it fits the foreground view, or if hiding, collapse back to the
	// pill view frame. also make our corner radius exactly half of the height so we get semicircle
	// edges
	if (direction) {
		[self._typeStatus_foregroundView layoutSubviews];
	}

	CGRect newFrame = direction ? [self _typeStatus_foregroundViewFrame] : pillView.frame;
	CGFloat newCornerRadius = direction ? newFrame.size.height / 2 : 0;

	if (direction) {
		// if we’re appearing, set the foreground view frame and force layout
		foregroundView.frame = newFrame;
		
		// if we’re appearing and reduce motion is enabled, set the frame now as it won’t be animated
		if (reduceMotion) {
			backgroundView.frame = newFrame;
			backgroundView.layer.cornerRadius = newCornerRadius;
		}
	}

	// if animated, use the same animation parameters used in status bar show/hide animations. else
	// use nil, which will just call the method instantly
	UIStatusBarHideAnimationParameters *animationParameters = animated ? [[%c(UIStatusBarHideAnimationParameters) alloc] initWithDefaultParameters] : nil;

	[%c(UIStatusBarAnimationParameters) animateWithParameters:(UIStatusBarAnimationParameters *)animationParameters animations:^{
		// the foreground view fades in regardless of the animation type
		foregroundView.alpha = direction ? 1 : 0;

		if (reduceMotion) {
			// do a simple fade to switch the two views over
			backgroundView.alpha = direction ? 1 : 0;
			pillView.alpha = direction ? 0 : 1;
		} else {
			// set our frame identically to how we did it above, and animate the foreground view alpha
			backgroundView.frame = newFrame;
			backgroundView.layer.cornerRadius = newCornerRadius;
		}
	} completion:^(BOOL finished) {
		// we’re no longer animating
		self._typeStatus_isAnimating = NO;
	}];
}

%new - (CGRect)_typeStatus_pillViewFrame {
	CGRect pillFrame = self.isHidden ? CGRectZero : [self _calculatePillFrame];

	// if the frame looks fishy, the home bar is probably being hidden by some other tweak. in this
	// case we try to roughly calculate its frame ourselves. otherwise the pill will probably show
	// at {0,0} and that’d really suck
	if (pillFrame.origin.y == 0 || pillFrame.size.width == 0) {
		pillFrame.size = [%c(MTLumaDodgePillView) suggestedSizeForContentWidth:self.frame.size.width];
		pillFrame.origin.x = (self.frame.size.width - pillFrame.size.width) / 2;
		pillFrame.origin.y = self.frame.size.height - [%c(MTLumaDodgePillView) suggestedEdgeSpacing] - pillFrame.size.height;
	}

	return pillFrame;
}

%new - (CGRect)_typeStatus_foregroundViewFrame {
	CGFloat edgeSpacing = [%c(MTLumaDodgePillView) suggestedEdgeSpacing];

	CGRect frame = self._typeStatus_pillViewFrame;
	frame.size = [self._typeStatus_foregroundView sizeThatFits:CGSizeMake(self.frame.size.width - (edgeSpacing * 2.f), kHBTSExpandedHomeGrabberHeight)];
	frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
	frame.origin.y = self.frame.size.height - edgeSpacing - frame.size.height;
	return frame;
}

- (void)_animateToStyle:(MTLumaDodgePillStyle)style disallowAdditive:(BOOL)disallowAdditive withAnimationSettings:(id)animationSettings {
	%orig;

	// if this style is different, update our views to follow the new style
	if (self._typeStatus_backgroundView.style != style) {
		self._typeStatus_backgroundView.style = style;
		[self _typeStatus_updateForegroundViewForPillStyle:style];
	}
}

- (void)layoutSubviews {
	%orig;

	// if we’re visible and not animating, update our frame
	if (self._typeStatus_isVisible && !self._typeStatus_isAnimating) {
		CGRect frame = [self _typeStatus_foregroundViewFrame];
		self._typeStatus_foregroundView.frame = frame;
		self._typeStatus_backgroundContainerView.frame = frame;
	}
}

- (void)dealloc {
	[[%c(HBTSStatusBarAlertController) sharedInstance] removeHomeGrabber:self];
	%orig;
}

%end

#pragma mark - Constructor

%ctor {
	// if SBHomeGrabberView is present, we can init these hooks. otherwise, they’re useless
	if (%c(SBHomeGrabberView)) {
		%init;
	}
}
