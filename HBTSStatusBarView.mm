#include <substrate.h> // ?!!?
#import "HBTSStatusBarView.h"
#import <UIKit/UIApplication+Private.h>
#import <UIKit/UIImage+Private.h>
#import <UIKit/UIStatusBar.h>
#import <UIKit/UIStatusBarForegroundView.h>
#import <version.h>
#include <notify.h>

#define IS_RETINA ([UIScreen mainScreen].scale > 1)
#define IS_MODERN IS_IOS_OR_NEWER(iOS_7_0)

static CGFloat const kHBTSStatusBarFontSize = IS_MODERN ? 12.f : 14.f;
static CGFloat const kHBTSStatusBarAnimationDuration = IS_MODERN ? .3f : 0.25f;
static CGFloat const kHBTSStatusBarAnimationDamping = 1.f;
static CGFloat const kHBTSStatusBarAnimationVelocity = 1.f;

@interface HBTSStatusBarView () {
	UIView *_containerView;
	UILabel *_typeLabel;
	UILabel *_contactLabel;
	UIImageView *_iconImageView;

	BOOL _isAnimating;
	BOOL _isVisible;
	NSTimer *_timer;
	HBTSStatusBarType _type;

	UIStatusBarStyle _previousStatusBarStyle;
	HBTSStatusBarType _previousType;

	CGFloat _foregroundViewAlpha;
	CGFloat _statusBarHeight;
	BOOL _isFirstTime;
	BOOL _statusBarWasHidden;
}

@end

@implementation HBTSStatusBarView

- (instancetype)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.clipsToBounds = NO;
		self.hidden = YES;

		_foregroundViewAlpha = 0;
		_statusBarHeight = frame.size.height;
		_isFirstTime = YES;

		_containerView = [[UIView alloc] initWithFrame:self.frame];
		_containerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[self addSubview:_containerView];

		_iconImageView = [[[UIImageView alloc] initWithImage:[UIImage kitImageNamed:@"WhiteOnBlackEtch_TypeStatus"]] autorelease];
		_iconImageView.center = CGPointMake(_iconImageView.center.x, self.frame.size.height / 2);
		_iconImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		[_containerView addSubview:_iconImageView];

		CGFloat top = -1.f;

		if (IS_MODERN) {
			top = 0;
		} else if (IS_RETINA) {
			top = -0.5f;
		}

		_typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_iconImageView.frame.size.width + 4.f, top, 0, self.frame.size.height)];
		_typeLabel.font = [UIFont boldSystemFontOfSize:kHBTSStatusBarFontSize];
		_typeLabel.backgroundColor = [UIColor clearColor];
		_typeLabel.textColor = [UIColor whiteColor];
		[_containerView addSubview:_typeLabel];

		_contactLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, top, 0, self.frame.size.height)];
		_contactLabel.font = [UIFont systemFontOfSize:kHBTSStatusBarFontSize];
		_contactLabel.backgroundColor = [UIColor clearColor];
		_contactLabel.textColor = [UIColor whiteColor];
		[_containerView addSubview:_contactLabel];
	}

	return self;
}

- (void)_updateForCurrentStatusBarStyle {
	static UIImage *TypingImage;
	static UIImage *TypingImageWhite;
	static UIImage *ReadImage;
	static UIImage *ReadImageWhite;
	static dispatch_once_t onceToken;

	dispatch_once(&onceToken, ^{
		if (IS_MODERN) {
			TypingImage = [[[UIImage kitImageNamed:@"Black_TypeStatus"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] retain];
			ReadImage = [[[UIImage kitImageNamed:@"Black_TypeStatusRead"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] retain];
		} else {
			TypingImage = [[UIImage kitImageNamed:@"WhiteOnBlackEtch_TypeStatus"] retain];
			ReadImage = [[UIImage kitImageNamed:@"WhiteOnBlackEtch_TypeStatusRead"] retain];
		}

		if (IS_IOS_OR_OLDER(iOS_5_1) && !IS_IPAD) {
			TypingImageWhite = [[UIImage kitImageNamed:@"ColorOnGrayShadow_TypeStatus"] retain];
			ReadImageWhite = [[UIImage kitImageNamed:@"ColorOnGrayShadow_TypeStatusRead"] retain];
		}
	});

	UIColor *textColor;
	UIColor *shadowColor;
	CGSize shadowOffset;
	BOOL isWhite = NO;

	if (!IS_IOS_OR_NEWER(iOS_6_0) && !IS_IPAD && [UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleDefault) {
		textColor = [UIColor blackColor];
		shadowColor = [UIColor whiteColor];
		shadowOffset = CGSizeMake(0, 1.f);
		isWhite = YES;
	} else {
		if (IS_MODERN && [UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleDefault) {
			textColor = [UIColor blackColor];
		} else {
			textColor = [UIColor whiteColor];
			shadowColor = [UIColor colorWithWhite:0 alpha:0.5f];
			shadowOffset = CGSizeMake(0, -1.f);
		}
	}

	if (_isFirstTime || _previousType != _type || _previousStatusBarStyle != [UIApplication sharedApplication].statusBarStyle) {
		switch (_type) {
			case HBTSStatusBarTypeTyping:
				_iconImageView.image = isWhite ? TypingImageWhite : TypingImage;
				break;

			case HBTSStatusBarTypeRead:
				_iconImageView.image = isWhite ? ReadImageWhite : ReadImage;
				break;
		}
	}

	_typeLabel.textColor = textColor;
	_contactLabel.textColor = textColor;

	if (IS_MODERN) {
		_iconImageView.tintColor = textColor;
	} else {
		_typeLabel.shadowColor = shadowColor;
		_contactLabel.shadowColor = shadowColor;

		_typeLabel.shadowOffset = shadowOffset;
		_contactLabel.shadowOffset = shadowOffset;
	}

	_isFirstTime = NO;
	_previousType = _type;
	_previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;
}

- (void)layoutSubviews {
	[super layoutSubviews];

	CGRect typeFrame = _typeLabel.frame;
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

- (void)showWithType:(HBTSStatusBarType)type name:(NSString *)name timeout:(NSTimeInterval)timeout {
	_type = type;
	_name = [name copy];

	switch (type) {
		case HBTSStatusBarTypeTyping:
			_typeLabel.text = L18N(@"Typing:");
			break;

		case HBTSStatusBarTypeRead:
			_typeLabel.text = L18N(@"Read:");
			break;
	}

	_contactLabel.text = _name;

	[self _updateForCurrentStatusBarStyle];
	[self layoutSubviews];

	if (_isAnimating || _isVisible) {
		return;
	}

	if (_timer) {
		[_timer invalidate];
		[_timer release];

		_timer = [[NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(hide) userInfo:nil repeats:NO] retain];

		return;
	}

	if (IN_SPRINGBOARD) {
		notify_post("ws.hbang.typestatus/OverlayWillShow");
	}

	UIStatusBarForegroundView *foregroundView = MSHookIvar<UIStatusBarForegroundView *>([UIApplication sharedApplication].statusBar, "_foregroundView");

	if (_foregroundViewAlpha == 0) {
		_foregroundViewAlpha = foregroundView.alpha;
	}

	_isAnimating = YES;
	_isVisible = YES;

	self.alpha = _foregroundViewAlpha;
	self.hidden = NO;
	self.frame = foregroundView.frame;

	void (^animationBlock)() = ^{
		if (_shouldSlide) {
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

		if (_shouldFade) {
			foregroundView.alpha = 0;
		}
	};

	void (^completionBlock)(BOOL finished) = ^(BOOL finished) {
		_isAnimating = NO;
		_timer = [[NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(hide) userInfo:nil repeats:NO] retain];
	};

	if (![UIApplication sharedApplication].statusBarHidden && (_shouldSlide || _shouldFade)) {
		CGRect frame = foregroundView.frame;
		frame.origin.y = _shouldSlide ? -_statusBarHeight : 0;
		self.frame = frame;

		if (_shouldFade) {
			self.alpha = 0;
		}

		if (IS_MODERN) {
			[UIView animateWithDuration:kHBTSStatusBarAnimationDuration delay:0 usingSpringWithDamping:kHBTSStatusBarAnimationDamping initialSpringVelocity:kHBTSStatusBarAnimationVelocity options:kNilOptions animations:animationBlock completion:completionBlock];
		} else {
			[UIView animateWithDuration:kHBTSStatusBarAnimationDuration animations:animationBlock completion:completionBlock];
		}

	} else {
		if ([UIApplication sharedApplication].statusBarHidden && !IN_SPRINGBOARD) {
			foregroundView.clipsToBounds = YES;

			CGRect foregroundFrame = foregroundView.frame;
			foregroundFrame.origin.y = _statusBarHeight;
			foregroundFrame.size.height = 0;
			foregroundView.frame = foregroundFrame;

			UIStatusBarAnimation animation = UIStatusBarAnimationNone;

			if (_shouldSlide) {
				animation = UIStatusBarAnimationSlide;
			} else if (_shouldFade) {
				animation = UIStatusBarAnimationFade;
			}

			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:animation];

			_statusBarWasHidden = YES;
			_previousStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;

			[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;

			if (_foregroundViewAlpha == 0) {
				_foregroundViewAlpha = foregroundView.alpha;
			}

			self.alpha = _foregroundViewAlpha == 0 ? 1.f : _foregroundViewAlpha;
		}

		foregroundView.alpha = 0;
		self.hidden = NO;
		completionBlock(YES);
	}
}

- (void)hide {
	if (!_timer || _isAnimating || !_isVisible) {
		return;
	}

	_isAnimating = YES;

	[_timer invalidate];
	[_timer release];
	_timer = nil;

	UIStatusBarForegroundView *foregroundView = MSHookIvar<UIStatusBarForegroundView *>([UIApplication sharedApplication].statusBar, "_foregroundView");

	void (^animationBlock)() = ^{
		if (_shouldSlide) {
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

	if (_statusBarWasHidden) {
		_statusBarWasHidden = NO;

		if (![UIApplication sharedApplication].statusBarHidden) {
			UIStatusBarAnimation animation = UIStatusBarAnimationNone;

			if (_shouldSlide) {
				animation = UIStatusBarAnimationSlide;
			} else if (_shouldFade) {
				animation = UIStatusBarAnimationFade;
			}

			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:animation];
		}

		if ([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleBlackTranslucent && [UIApplication sharedApplication].statusBarStyle != _previousStatusBarStyle) {
			[[UIApplication sharedApplication] setStatusBarStyle:_previousStatusBarStyle animated:YES];
		}
	}

	if (![UIApplication sharedApplication].statusBarHidden && (_shouldSlide || _shouldFade)) {
		if (IS_MODERN) {
			[UIView animateWithDuration:kHBTSStatusBarAnimationDuration delay:0 usingSpringWithDamping:kHBTSStatusBarAnimationDamping initialSpringVelocity:kHBTSStatusBarAnimationVelocity options:kNilOptions animations:animationBlock completion:completionBlock];
		} else {
			[UIView animateWithDuration:kHBTSStatusBarAnimationDuration animations:animationBlock completion:completionBlock];
		}
	} else {
		foregroundView.hidden = NO;
		completionBlock(YES);
	}
}

- (void)dealloc {
	[_containerView release];
	[_typeLabel release];
	[_contactLabel release];
	[_iconImageView release];
	[_timer release];

	[super dealloc];
}

@end
