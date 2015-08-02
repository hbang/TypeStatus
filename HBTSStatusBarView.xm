#include <substrate.h>
#import "HBTSStatusBarView.h"
#import "HBTSPreferences.h"
#import <Foundation/NSDistributedNotificationCenter.h>
#import <SpringBoard/SBChevronView.h>
#import <SpringBoard/SBLockScreenManager.h>
#import <SpringBoard/SBLockScreenViewController.h>
#import <SpringBoard/SBLockScreenView.h>
#import <UIKit/UIApplication+Private.h>
#import <UIKit/UIImage+Private.h>
#import <UIKit/UIStatusBar.h>
#import <UIKit/UIStatusBarForegroundView.h>
#import <UIKit/UIStatusBarForegroundStyleAttributes.h>
#include <notify.h>

static CGFloat const kHBTSStatusBarFontSize = 12.f;
static NSTimeInterval const kHBTSStatusBarAnimationDuration = 0.25;

@implementation HBTSStatusBarView {
	UIView *_containerView;
	UILabel *_typeLabel;
	UILabel *_contactLabel;
	UIImageView *_iconImageView;

	BOOL _isAnimating;
	BOOL _isVisible;
	HBTSStatusBarType _type;
	HBTSStatusBarAnimation _animations;

	CGFloat _foregroundViewAlpha;
	CGFloat _statusBarHeight;
	BOOL _topGrabberWasHidden;

	NSTimer *_hideTimer;
}

#pragma mark - UIView

- (instancetype)initWithFrame:(CGRect)frame {
	frame.size.height = [UIStatusBar heightForStyle:UIStatusBarStyleDefault orientation:UIInterfaceOrientationPortrait];
	self = [super initWithFrame:frame];

	if (self) {
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.clipsToBounds = NO;
		self.hidden = YES;

		_foregroundViewAlpha = 0;
		_statusBarHeight = frame.size.height;

		_containerView = [[UIView alloc] initWithFrame:self.bounds];
		_containerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[self addSubview:_containerView];

		_iconImageView = [[[UIImageView alloc] init] autorelease];
		_iconImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		_iconImageView.center = CGPointMake(_iconImageView.center.x, self.frame.size.height / 2);
		[_containerView addSubview:_iconImageView];

		_typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 0, self.frame.size.height)];
		_typeLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		_typeLabel.font = [UIFont boldSystemFontOfSize:kHBTSStatusBarFontSize];
		_typeLabel.backgroundColor = [UIColor clearColor];
		_typeLabel.textColor = [UIColor whiteColor];
		[_containerView addSubview:_typeLabel];

		_contactLabel = [[UILabel alloc] initWithFrame:_typeLabel.frame];
		_contactLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		_contactLabel.font = [UIFont systemFontOfSize:kHBTSStatusBarFontSize];
		_contactLabel.backgroundColor = [UIColor clearColor];
		_contactLabel.textColor = [UIColor whiteColor];
		[_containerView addSubview:_contactLabel];

		[[NSDistributedNotificationCenter defaultCenter] addObserver:self selector:@selector(receivedStatusNotification:) name:HBTSClientSetStatusBarNotification object:nil];
	}

	return self;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	_iconImageView.frame = (CGRect){ CGPointZero, _iconImageView.image.size };

	CGRect typeFrame = _typeLabel.frame;
	typeFrame.origin.x = _iconImageView.frame.size.width + 4.f;
	typeFrame.size.width = [_typeLabel sizeThatFits:self.frame.size].width;
	_typeLabel.frame = typeFrame;

	CGRect labelFrame = _contactLabel.frame;
	labelFrame.origin.x = typeFrame.origin.x + typeFrame.size.width + 4.f;
	labelFrame.size.width = [_contactLabel sizeThatFits:self.frame.size].width;
	_contactLabel.frame = labelFrame;

	CGRect containerFrame = _containerView.frame;
	containerFrame.size.width = labelFrame.origin.x + labelFrame.size.width;
	_containerView.frame = containerFrame;

	_containerView.center = CGPointMake(self.frame.size.width / 2, _containerView.center.y);
}

#pragma mark - Adapting UI

- (void)_updateForCurrentStatusBarStyle {
	static UIImage *TypingImage;
	static UIImage *ReadImage;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSBundle *uikitBundle = [NSBundle bundleForClass:UIView.class];

		TypingImage = [[[UIImage imageNamed:@"Black_TypeStatus" inBundle:uikitBundle] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] retain];
		ReadImage = [[[UIImage imageNamed:@"Black_TypeStatusRead" inBundle:uikitBundle] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] retain];
	});

	UIStatusBarForegroundView *foregroundView = MSHookIvar<UIStatusBarForegroundView *>(self.superview, "_foregroundView");
	UIColor *textColor = MSHookIvar<UIColor *>(foregroundView.foregroundStyle, "_tintColor");

	_typeLabel.textColor = textColor;
	_contactLabel.textColor = textColor;
	_iconImageView.tintColor = textColor;

	switch (_type) {
		case HBTSStatusBarTypeTyping:
			_iconImageView.image = TypingImage;
			break;

		case HBTSStatusBarTypeRead:
			_iconImageView.image = ReadImage;
			break;

		case HBTSStatusBarTypeTypingEnded:
			break;
	}
}

- (BOOL)statusBarWentPoof {
	if (!self.superview || ![self.superview isKindOfClass:UIStatusBar.class]) {
		return YES;
	}

	return NO;
}

#pragma mark - Show/hide

- (void)receivedStatusNotification:(NSNotification *)notification {
	if (self.statusBarWentPoof) {
		return;
	}

	HBTSPreferences *preferences = [HBTSPreferences sharedInstance];

	HBTSStatusBarType type = (HBTSStatusBarType)((NSNumber *)notification.userInfo[kHBTSMessageTypeKey]).intValue;
	BOOL typing = ((NSNumber *)notification.userInfo[kHBTSMessageIsTypingKey]).boolValue;
	BOOL typingTimeout = preferences.useTypingTimeout;

	NSTimeInterval duration = kHBTSTypingTimeout;

	if (!typing || typingTimeout) {
		duration = preferences.overlayDisplayDuration;
	}

	if ([[NSDate date] timeIntervalSinceDate:notification.userInfo[kHBTSMessageSendDateKey]] > duration) {
		return;
	}

	_animations = preferences.overlayAnimation;

	if (type == HBTSStatusBarTypeTypingEnded) {
		[self hide];
	} else {
		_type = type;
		_contactLabel.text = notification.userInfo[kHBTSMessageSenderKey];

		[self showWithTimeout:duration];
	}
}

- (void)showWithTimeout:(NSTimeInterval)timeout {
	if (self.statusBarWentPoof || [UIApplication sharedApplication].statusBarHidden) {
		return;
	}

	static NSBundle *PrefsBundle;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		PrefsBundle = [[NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatus.bundle"] retain];
	});

	switch (_type) {
		case HBTSStatusBarTypeTyping:
			_typeLabel.text = [PrefsBundle localizedStringForKey:@"Typing:" value:@"Typing:" table:@"Root"];
			break;

		case HBTSStatusBarTypeRead:
			_typeLabel.text = [PrefsBundle localizedStringForKey:@"Read:" value:@"Read:" table:@"Root"];
			break;

		case HBTSStatusBarTypeTypingEnded:
			break;
	}

	[self _updateForCurrentStatusBarStyle];
	[self layoutSubviews];

	if (_isAnimating || _isVisible) {
		return;
	}

	if (_hideTimer) {
		[_hideTimer invalidate];
		[_hideTimer release];

		_hideTimer = [[NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(hide) userInfo:nil repeats:NO] retain];

		return;
	}

	if (IN_SPRINGBOARD) {
		notify_post("ws.hbang.typestatus/OverlayWillShow");

		if (UIAccessibilityIsVoiceOverRunning()) {
			UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, [NSString stringWithFormat:@"%@ %@", _typeLabel.text, _contactLabel.text]);
		}
	}

	UIStatusBarForegroundView *foregroundView = MSHookIvar<UIStatusBarForegroundView *>(self.superview, "_foregroundView");

	if (_foregroundViewAlpha == 0) {
		_foregroundViewAlpha = foregroundView.alpha;
	}

	_isAnimating = YES;
	_isVisible = YES;

	self.alpha = _foregroundViewAlpha;
	self.hidden = NO;
	self.frame = foregroundView.frame;

	void (^animationBlock)() = ^{
		if (_animations & HBTSStatusBarAnimationSlide) {
			CGRect frame = self.frame;
			frame.origin.y = 0;
			self.frame = frame;

			foregroundView.clipsToBounds = YES;

			CGRect foregroundFrame = foregroundView.frame;
			foregroundFrame.origin.y = _statusBarHeight;
			foregroundFrame.size.height = 0;
			foregroundView.frame = foregroundFrame;
		}

		self.alpha = _foregroundViewAlpha;

		if (_animations & HBTSStatusBarAnimationFade) {
			foregroundView.alpha = 0;
		}

		[self _toggleLockScreenGrabberVisible:NO];
	};

	void (^completionBlock)(BOOL finished) = ^(BOOL finished) {
		_isAnimating = NO;
		_hideTimer = [[NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(hide) userInfo:nil repeats:NO] retain];
	};

	if (_animations == HBTSStatusBarAnimationNone) {
		foregroundView.hidden = YES;
		self.hidden = NO;
		completionBlock(YES);
	} else {
		CGRect frame = foregroundView.frame;
		frame.origin.y = _animations & HBTSStatusBarAnimationSlide ? -_statusBarHeight : 0;
		self.frame = frame;

		if (_animations & HBTSStatusBarAnimationFade) {
			self.alpha = 0;
		}

		[UIView animateWithDuration:kHBTSStatusBarAnimationDuration animations:animationBlock completion:completionBlock];
	}
}

- (void)hide {
	if (self.statusBarWentPoof || !_hideTimer || _isAnimating || !_isVisible) {
		return;
	}

	_isAnimating = YES;

	[_hideTimer invalidate];
	[_hideTimer release];
	_hideTimer = nil;

	UIStatusBarForegroundView *foregroundView = MSHookIvar<UIStatusBarForegroundView *>(self.superview, "_foregroundView");

	void (^animationBlock)() = ^{
		if (_animations & HBTSStatusBarAnimationSlide) {
			CGRect frame = self.frame;
			frame.origin.y = -_statusBarHeight;
			self.frame = frame;
		}

		CGRect foregroundFrame = foregroundView.frame;
		foregroundFrame.origin.y = 0;
		foregroundFrame.size.height = _statusBarHeight;
		foregroundView.frame = foregroundFrame;

		self.alpha = 0;
		foregroundView.alpha = _foregroundViewAlpha;

		[self _toggleLockScreenGrabberVisible:YES];
	};

	void (^completionBlock)(BOOL finished) = ^(BOOL finished) {
		self.hidden = YES;
		self.frame = foregroundView.frame;
		self.alpha = _foregroundViewAlpha;

		foregroundView.clipsToBounds = NO;

		_typeLabel.text = @"";
		_contactLabel.text = @"";

		_isAnimating = NO;
		_isVisible = NO;

		if (IN_SPRINGBOARD) {
			notify_post("ws.hbang.typestatus/OverlayDidHide");
		}
	};

	if (_animations == HBTSStatusBarAnimationNone) {
		foregroundView.hidden = NO;
		completionBlock(YES);
	} else {
		[UIView animateWithDuration:kHBTSStatusBarAnimationDuration animations:animationBlock completion:completionBlock];
	}
}

- (void)_toggleLockScreenGrabberVisible:(BOOL)state {
	SBLockScreenManager *lockScreenManager = [%c(SBLockScreenManager) sharedInstance];

	if (!lockScreenManager.isUILocked) {
		return;
	}

	SBLockScreenView *lockScreenView = (SBLockScreenView *)lockScreenManager.lockScreenViewController.view;
	SBChevronView *topGrabberView = lockScreenView.topGrabberView;

	if (state && !_topGrabberWasHidden) {
		topGrabberView.alpha = 1;
	} else if (!state) {
		_topGrabberWasHidden = topGrabberView.alpha == 0;
		topGrabberView.alpha = 0;
	}
}

#pragma mark - Memory management

- (void)dealloc {
	[_containerView release];
	[_typeLabel release];
	[_contactLabel release];
	[_iconImageView release];
	[_hideTimer release];

	[[NSDistributedNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}

@end
