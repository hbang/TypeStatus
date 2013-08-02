#include <substrate.h> // ?!!?
#import "HBTSStatusBarView.h"
#import <UIKit/UIApplication+Private.h>
#import <UIKit/UIImage+Private.h>
#import <UIKit/UIStatusBar.h>
#import <version.h>
#include <notify.h>

#define IS_RETINA ([UIScreen mainScreen].scale > 1)

#define kHBTSStatusBarFontSize 14.f
#define kHBTSStatusBarAnimationDuration 0.25f

@implementation HBTSStatusBarView
@synthesize shouldSlide = _shouldSlide, shouldFade = _shouldFade;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.clipsToBounds = NO;
		self.hidden = YES;

		_foregroundViewAlpha = 0;
		_statusBarHeight = frame.size.height;

		_containerView = [[UIView alloc] initWithFrame:self.frame];
		_containerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[self addSubview:_containerView];

		_iconImageView = [[[UIImageView alloc] initWithImage:[UIImage kitImageNamed:@"WhiteOnBlackEtch_TypeStatus"]] autorelease];
		_iconImageView.center = CGPointMake(_iconImageView.center.x, self.frame.size.height / 2);
		_iconImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		[_containerView addSubview:_iconImageView];

		_typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_iconImageView.frame.size.width + 4.f, IS_RETINA ? -0.5f : -1.f, 0, self.frame.size.height)];
		_typeLabel.font = [UIFont boldSystemFontOfSize:kHBTSStatusBarFontSize];
		_typeLabel.backgroundColor = [UIColor clearColor];
		_typeLabel.textColor = [UIColor whiteColor];
		[_containerView addSubview:_typeLabel];

		_contactLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, IS_RETINA ? -0.5f : -1.f, 0, self.frame.size.height)];
		_contactLabel.font = [UIFont systemFontOfSize:kHBTSStatusBarFontSize];
		_contactLabel.backgroundColor = [UIColor clearColor];
		_contactLabel.textColor = [UIColor whiteColor];
		[_containerView addSubview:_contactLabel];
	}

	return self;
}

- (void)_updateForCurrentStatusBarStyle {
	NSString *prefix;

	if (!IS_IOS_OR_NEWER(iOS_6_0) && !IS_IPAD && [UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleDefault) {
		prefix = @"ColorOnGrayShadow_";

		_typeLabel.textColor = [UIColor blackColor];
		_contactLabel.textColor = [UIColor blackColor];

		_typeLabel.shadowColor = [UIColor whiteColor];
		_contactLabel.shadowColor = [UIColor whiteColor];

		_typeLabel.shadowOffset = CGSizeMake(0, 1.f);
		_contactLabel.shadowOffset = CGSizeMake(0, 1.f);
	} else {
		prefix = @"WhiteOnBlackEtch_";

		_typeLabel.textColor = [UIColor whiteColor];
		_contactLabel.textColor = [UIColor whiteColor];

		_typeLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5f];
		_contactLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5f];

		_typeLabel.shadowOffset = CGSizeMake(0, -1.f);
		_contactLabel.shadowOffset = CGSizeMake(0, -1.f);
	}

	NSString *iconName;

	switch (_type) {
		case HBTSStatusBarTypeTyping:
			iconName = @"TypeStatus";
			break;

		case HBTSStatusBarTypeRead:
			iconName = @"TypeStatusRead";
			break;
	}

	_iconImageView.image = [UIImage kitImageNamed:[prefix stringByAppendingString:iconName]];
}

- (NSString *)string {
	return _contactLabel.text;
}

- (void)setString:(NSString *)string {
	if (string) {
		_contactLabel.text = string ?: @"";

		CGRect labelFrame = _contactLabel.frame;
		labelFrame.size.width = (int)[_contactLabel.text sizeWithFont:_contactLabel.font constrainedToSize:self.frame.size lineBreakMode:UILineBreakModeTailTruncation].width;
		_contactLabel.frame = labelFrame;

		CGRect containerFrame = _containerView.frame;
		containerFrame.size.width = _contactLabel.frame.origin.x + _contactLabel.frame.size.width;
		_containerView.frame = containerFrame;

		_containerView.center = CGPointMake(self.frame.size.width / 2.f, _containerView.center.y);
	} else {
		[self hide];
	}
}

- (HBTSStatusBarType)type {
	return _type;
}

- (void)setType:(HBTSStatusBarType)type {
	_type = type;

	switch (type) {
		case HBTSStatusBarTypeTyping:
			_typeLabel.text = I18N(@"Typing:");
			break;

		case HBTSStatusBarTypeRead:
			_typeLabel.text = I18N(@"Read:");
			break;
	}

	[self _updateForCurrentStatusBarStyle];

	CGRect typeFrame = _typeLabel.frame;
	typeFrame.size.width = (int)[_typeLabel.text sizeWithFont:_typeLabel.font constrainedToSize:self.frame.size lineBreakMode:UILineBreakModeTailTruncation].width;
	_typeLabel.frame = typeFrame;

	CGRect labelFrame = _contactLabel.frame;
	labelFrame.origin.x = typeFrame.origin.x + typeFrame.size.width + 4.f;
	_contactLabel.frame = labelFrame;
}

- (void)showWithTimeout:(double)timeout {
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

		[UIView animateWithDuration:kHBTSStatusBarAnimationDuration animations:^{
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
		} completion:completionBlock];
	} else {
		foregroundView.hidden = YES;
		completionBlock(YES);

		if ([UIApplication sharedApplication].statusBarHidden && !IN_SPRINGBOARD) {
			UIStatusBarAnimation animation = UIStatusBarAnimationNone;

			if (_shouldSlide) {
				animation = UIStatusBarAnimationSlide;
			} else if (_shouldFade) {
				animation = UIStatusBarAnimationFade;
			}

			[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:animation];

			_statusBarWasHidden = YES;
			_oldStatusBarStyle = [UIApplication sharedApplication].statusBarStyle;

			[UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackTranslucent;
		}
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
		if (![UIApplication sharedApplication].statusBarHidden) {
			UIStatusBarAnimation animation = UIStatusBarAnimationNone;

			if (_shouldSlide) {
				animation = UIStatusBarAnimationSlide;
			} else if (_shouldFade) {
				animation = UIStatusBarAnimationFade;
			}

			[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:animation];

			_statusBarWasHidden = NO;
		}

		if ([UIApplication sharedApplication].statusBarStyle == UIStatusBarStyleBlackTranslucent && [UIApplication sharedApplication].statusBarStyle != _oldStatusBarStyle) {
			[[UIApplication sharedApplication] setStatusBarStyle:_oldStatusBarStyle animated:YES];
		}

		dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.3 * NSEC_PER_SEC), dispatch_get_current_queue(), ^{
			foregroundView.hidden = NO;
			completionBlock(YES);
		});
	} else if (_shouldSlide || _shouldFade) {
		[UIView animateWithDuration:kHBTSStatusBarAnimationDuration animations:^{
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
		} completion:completionBlock];
	} else {
		foregroundView.hidden = NO;
		completionBlock(YES);
	}
}
@end
