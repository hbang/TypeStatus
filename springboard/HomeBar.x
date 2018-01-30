#import "../client/HBTSStatusBarForegroundView.h"
#import "HBTSStatusBarAlertController.h"
#import "HBTSPreferences.h"
#import <SpringBoard/SBHomeGrabberView.h>
#import <MaterialKit/MTLumaDodgePillView.h>
#import <UIKit/UIStatusBarAnimationParameters.h>
#import <UIKit/UIStatusBarForegroundStyleAttributes.h>

#pragma mark - SBHomeGrabberView category

@interface SBHomeGrabberView (TypeStatus)

@property (nonatomic, retain) MTLumaDodgePillView *_typeStatus_backgroundView;
@property (nonatomic, retain) HBTSStatusBarForegroundView *_typeStatus_foregroundView;

@property BOOL _typeStatus_isAnimating;
@property BOOL _typeStatus_isVisible;

- (CGRect)_typeStatus_pillViewFrame;
- (CGRect)_typeStatus_foregroundViewFrame;

@end

#pragma mark - Hooks

%hook SBHomeGrabberView

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

		MTLumaDodgePillView *backgroundView = [[%c(MTLumaDodgePillView) alloc] init];
		backgroundView.hidden = YES;
		[self addSubview:backgroundView];
		self._typeStatus_backgroundView = backgroundView;

		HBTSStatusBarForegroundView *foregroundView = [[%c(HBTSStatusBarForegroundView) alloc] initWithFrame:CGRectZero foregroundStyle:nil usesVerticalLayout:NO];
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
	if (direction) {
		if (self._typeStatus_isVisible || self._typeStatus_isAnimating) {
			return;
		}

		self._typeStatus_isAnimating = YES;
	} else if (!self._typeStatus_isVisible || self._typeStatus_isAnimating) {
		return;
	}

	HBTSStatusBarAnimation animation = ((HBTSPreferences *)[%c(HBTSPreferences) sharedInstance]).overlayAnimation;

	HBTSStatusBarForegroundView *foregroundView = self._typeStatus_foregroundView;
	MTLumaDodgePillView *backgroundView = self._typeStatus_backgroundView;
	MTLumaDodgePillView *pillView = [self valueForKey:@"_pillView"];

	// set our state based on the direction and whether we’re animating
	self._typeStatus_isVisible = direction;
	self._typeStatus_isAnimating = animated;

	if (animated) {
		if (animation == HBTSStatusBarAnimationSlide) {
			// if showing, set the initial frame of the background view to the frame of the pill view, so
			// we can seamlessly switch between them
			if (direction) {
				backgroundView.frame = pillView.frame;
			}

			// force the background view to visible, and the pill view to hidden. we use our separate
			// pill view (background view) so we work regardless of whether another tweak is hiding the
			// system pill view
			backgroundView.hidden = NO;
			backgroundView.alpha = 1;
			pillView.hidden = YES;
			pillView.alpha = 0;
		} else {
			// if fading or no-animation, ensure we have our initial state
			backgroundView.alpha = direction ? 0 : 1;
			pillView.alpha = direction ? 1 : 0;
		}

		// regardless of the animation, the foreground view fades. set the initial state of that
		foregroundView.alpha = direction ? 0 : 1;
	}

	UIStatusBarHideAnimationParameters *animationParameters = animated ? [[%c(UIStatusBarHideAnimationParameters) alloc] initWithDefaultParameters] : nil;

	[%c(UIStatusBarAnimationParameters) animateWithParameters:(UIStatusBarAnimationParameters *)animationParameters animations:^{
		if (animation == HBTSStatusBarAnimationSlide) {
			// if showing, expand the background view so it fits the foreground view, or if hiding,
			// collapse back to the pill view frame
			backgroundView.frame = direction ? [self _typeStatus_foregroundViewFrame] : pillView.frame;
		} else {
			// do a simple fade to switch the two views over
			backgroundView.alpha = direction ? 1 : 0;
			pillView.alpha = direction ? 0 : 1;
		}

		foregroundView.alpha = direction ? 0 : 1;
	} completion:^(BOOL finished) {
		// we’re no longer animating
		self._typeStatus_isAnimating = NO;

		// set hidden on both views based on the direction
		backgroundView.hidden = !direction;
		pillView.hidden = direction;
	}];
}

%new - (CGRect)_typeStatus_pillViewFrame {
	CGRect pillFrame = [self _calculatePillFrame];

	// if the frame looks fishy, the home bar is probably being hidden by some other tweak. in this
	// case we try to roughly calculate its frame ourselves. otherwise the pill 
	if (pillFrame.origin.y == 0 || pillFrame.size.width == 0) {
		pillFrame.size = [%c(MTLumaDodgePillView) suggestedSizeForContentWidth:self.frame.size.width];
		pillFrame.origin.x = (self.frame.size.width - pillFrame.size.width) / 2;
		pillFrame.origin.y = self.frame.size.height - [%c(MTLumaDodgePillView) suggestedEdgeSpacing] - pillFrame.size.height;
	}

	return pillFrame;
}

%new - (CGRect)_typeStatus_foregroundViewFrame {
	CGRect frame = self._typeStatus_pillViewFrame;
	frame.size.height = 20;
	frame.size.width = [self._typeStatus_foregroundView sizeThatFits:CGSizeMake(self.frame.size.width, frame.size.height)].width;
	frame.origin.x = (self.frame.size.width - frame.size.width) / 2;
	frame.origin.y = self.frame.size.height - [%c(MTLumaDodgePillView) suggestedEdgeSpacing] - frame.size.height;
	return frame;
}

- (void)layoutSubviews {
	%orig;

	// if we’re visible and not animating, update our frame
	if (self._typeStatus_isVisible && !self._typeStatus_isAnimating) {
		self._typeStatus_backgroundView.frame = [self _typeStatus_foregroundViewFrame];
	}
}

- (void)dealloc {
	[[%c(HBTSStatusBarAlertController) sharedInstance] removeHomeGrabber:self];
	%orig;
}

%end

// TESTING
%hook SBHomeGrabberSettings
-(BOOL)isEnabled{return 1;}
%end
// /TESTING

#pragma mark - Constructor

%ctor {
	// if SBHomeGrabberView is present, we can init these hooks. otherwise, they’re useless
	if (%c(SBHomeGrabberView)) {
		%init;
	}
}
