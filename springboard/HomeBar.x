#import "../client/HBTSStatusBarForegroundView.h"
#import "HBTSStatusBarAlertController.h"
#import "HBTSPreferences.h"
#import <SpringBoard/SBHomeGrabberView.h>
#import <MaterialKit/MTLumaDodgePillView.h>
#import <UIKit/UIStatusBarAnimationParameters.h>
#import <UIKit/UIStatusBarForegroundStyleAttributes.h>

static CGFloat const kHBTSExpandedHomeGrabberHeight = 20.f;

#pragma mark - SBHomeGrabberView category

@interface SBHomeGrabberView (TypeStatus)

@property (nonatomic, retain) UIView *_typeStatus_typeStatusView;
@property (nonatomic, retain) MTLumaDodgePillView *_typeStatus_backgroundView;
@property (nonatomic, retain) HBTSStatusBarForegroundView *_typeStatus_foregroundView;

@property BOOL _typeStatus_isAnimating;
@property BOOL _typeStatus_isVisible;

- (CGRect)_typeStatus_pillViewFrame;
- (CGRect)_typeStatus_foregroundViewFrame;

@end

#pragma mark - Hooks

%hook SBHomeGrabberView

%property (nonatomic, retain) UIView *_typeStatus_typeStatusView;
%property (nonatomic, retain) MTLumaDodgePillView *_typeStatus_backgroundView;
%property (nonatomic, retain) HBTSStatusBarForegroundView *_typeStatus_foregroundView;

%property (assign) BOOL _typeStatus_isAnimating;
%property (assign) BOOL _typeStatus_isVisible;

#pragma mark - Initialization

- (instancetype)initWithFrame:(CGRect)frame {
	self = %orig;

	if (self) {
		HBTSStatusBarAlertController *alertController = [%c(HBTSStatusBarAlertController) sharedInstance];
		[alertController addHomeGrabber:self];

		UIView *typeStatusView = [[UIView alloc] init];
		typeStatusView.alpha = 0;
		typeStatusView.clipsToBounds = YES;
		[self addSubview:typeStatusView];
		self._typeStatus_typeStatusView = typeStatusView;

		MTLumaDodgePillView *backgroundView = [[%c(MTLumaDodgePillView) alloc] initWithFrame:typeStatusView.bounds];
		backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[typeStatusView addSubview:backgroundView];
		self._typeStatus_backgroundView = backgroundView;

		UIStatusBarForegroundStyleAttributes *foregroundStyle = [[%c(UIStatusBarForegroundStyleAttributes) alloc] initWithHeight:kHBTSExpandedHomeGrabberHeight legibilityStyle:0 tintColor:[UIColor whiteColor] hasBusyBackground:NO];

		HBTSStatusBarForegroundView *foregroundView = [[%c(HBTSStatusBarForegroundView) alloc] initWithFrame:typeStatusView.bounds foregroundStyle:foregroundStyle usesVerticalLayout:NO];
		foregroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[typeStatusView addSubview:backgroundView];
		self._typeStatus_foregroundView = foregroundView;

		[alertController displayCurrentAlertInHomeGrabber:self animated:NO];
	}

	return self;
}

- (void)_animateToStyle:(MTLumaDodgePillStyle)style disallowAdditive:(BOOL)disallowAdditive withAnimationSettings:(id)animationSettings {
	%orig;

	if (self._typeStatus_backgroundView.style != style) {
		self._typeStatus_backgroundView.style = style;
	}
}

%new - (void)_typeStatus_changeToDirection:(BOOL)direction animated:(BOOL)animated {
	// YES direction is show, NO is hide
	// if we’re currently animating, or the direction matches the current visibility, ignore
	if (self._typeStatus_isAnimating || self._typeStatus_isVisible == direction) {
		return;
	}

	// words you will be confused by while reading this code:
	// • pill view: the regular home bar displayed by the system. we just show/hide this, nothing else
	// • background view: an almost-identical clone of the pill view, used for our own needs,
	//   including animations
	// • foreground view: the typestatus notification icon and text we all know and love. this is just
	//   faded in and out
	HBTSStatusBarForegroundView *foregroundView = self._typeStatus_foregroundView;
	UIView *typeStatusView = self._typeStatus_typeStatusView;
	MTLumaDodgePillView *pillView = [self valueForKey:@"_pillView"];

	// set our state based on the direction and whether we’re animating
	self._typeStatus_isVisible = direction;
	self._typeStatus_isAnimating = animated;

	BOOL reduceMotion = ((HBTSPreferences *)[%c(HBTSPreferences) sharedInstance]).reduceMotion;

	// figure out whether the pill is hidden by another tweak, so we won’t mess it up for the user
	// BOOL wasPillHidden = (direction && pillView.hidden) || !pillView.superview;

	if (animated) {
		// regardless of the animation, the foreground view fades. set the initial state of that
		foregroundView.alpha = direction ? 0 : 1;

		if (reduceMotion) {
			// if fading or no-animation, ensure we have our initial state
			typeStatusView.alpha = direction ? 0 : 1;
			pillView.alpha = direction ? 1 : 0;
		} else {
			// if showing, set the initial frame of the background view to the frame of the pill view, so
			// we can seamlessly switch between them
			if (direction) {
				typeStatusView.frame = pillView.frame;
			}

			// force our view to visible, and the pill view to hidden. we use our separate pill view
			// (background view) so we work regardless of whether another tweak is hiding the system pill
			// pill view
			typeStatusView.alpha = 1;
			pillView.alpha = 0;
		}
	}

	// if showing, expand our view so it fits the foreground view, or if hiding, collapse back to
	// the pill view frame. also make our corner radius exactly half of the height so we get
	// semicircle edges
	CGRect newFrame = direction ? [self _typeStatus_foregroundViewFrame] : pillView.frame;
	CGFloat newCornerRadius = direction ? newFrame.size.height / 2 : 0;

	// if we’re appearing and reduce motion is enabled, set the frame now as it won’t be animated
	if (reduceMotion && direction) {
		typeStatusView.frame = newFrame;
		typeStatusView.layer.cornerRadius = newCornerRadius;
	}

	// force layout right now (right here, right now, right here, right now, right here, right now, …)
	[foregroundView layoutSubviews];

	// if animated, use the same animation parameters used in status bar show/hide animations. else
	// use nil, which will just call the method instantly
	UIStatusBarHideAnimationParameters *animationParameters = animated ? [[%c(UIStatusBarHideAnimationParameters) alloc] initWithDefaultParameters] : nil;

	[%c(UIStatusBarAnimationParameters) animateWithParameters:(UIStatusBarAnimationParameters *)animationParameters animations:^{
		if (reduceMotion) {
			// do a simple fade to switch the two views over
			typeStatusView.alpha = direction ? 1 : 0;
			pillView.alpha = direction ? 0 : 1;
		} else {
			// set our frame identically to how we did it above, and animate the foreground view alpha
			typeStatusView.frame = newFrame;
			typeStatusView.layer.cornerRadius = newCornerRadius;
			foregroundView.alpha = direction ? 1 : 0;
		}
	} completion:^(BOOL finished) {
		// we’re no longer animating
		self._typeStatus_isAnimating = NO;
	}];
}

%new - (CGRect)_typeStatus_pillViewFrame {
	CGRect pillFrame = [self _calculatePillFrame];

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
	// frame.size = [self._typeStatus_foregroundView sizeThatFits:CGSizeMake(self.frame.size.width - (edgeSpacing * 2.f), kHBTSExpandedHomeGrabberHeight)];
	frame.size = (CGSize){ 300, kHBTSExpandedHomeGrabberHeight };
	frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
	frame.origin.y = self.frame.size.height - edgeSpacing - frame.size.height;
	return frame;
}

- (void)layoutSubviews {
	%orig;

	// if we’re visible and not animating, update our frame
	if (self._typeStatus_isVisible && !self._typeStatus_isAnimating) {
		self._typeStatus_typeStatusView.frame = [self _typeStatus_foregroundViewFrame];
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
