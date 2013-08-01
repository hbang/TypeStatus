#include <substrate.h> // ?!!?
#import "HBTSStatusBarView.h"
#import <UIKit/UIApplication+Private.h>
#import <UIKit/UIImage+Private.h>
#import <UIKit/UIStatusBar.h>
#import <version.h>
#include <notify.h>

#define IS_RETINA ([UIScreen mainScreen].scale > 1)

#define kHBTSStatusBarHeight 20.f
#define kHBTSStatusBarFontSize 14.f

@implementation HBTSStatusBarView
@synthesize shouldSlide = _shouldSlide, shouldFade = _shouldFade;

- (id)initWithFrame:(CGRect)frame {
	self = [super initWithFrame:frame];

	if (self) {
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		self.clipsToBounds = NO;
		self.hidden = YES;

		_foregroundViewAlpha = 0;

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

	self.hidden = NO;
	_isAnimating = YES;
	_isVisible = YES;

	if (_shouldSlide) {
		CGRect frame = self.frame;
		frame.origin.y = -kHBTSStatusBarHeight;
		self.frame = frame;
	}

	self.alpha = _shouldFade ? 0 : _foregroundViewAlpha;
	self.hidden = NO;

	[UIView animateWithDuration:_shouldSlide || _shouldFade ? 0.3f : 0 animations:^{
		if (_shouldSlide) {
			CGRect frame = self.frame;
			frame.origin.y = 0;
			self.frame = frame;

			foregroundView.clipsToBounds = YES;

			CGRect foregroundFrame = foregroundView.frame;
			foregroundFrame.origin.y = kHBTSStatusBarHeight;
			foregroundFrame.size.height = 0;
			foregroundView.frame = foregroundFrame;
		}

		self.alpha = _foregroundViewAlpha;

		if (_shouldFade || !_shouldSlide) {
			foregroundView.alpha = 0;
		}
	} completion:^(BOOL finished) {
		_isAnimating = NO;
		_timer = [[NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(hide) userInfo:nil repeats:NO] retain];
	}];
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

	[UIView animateWithDuration:0.3f animations:^{
		if (_shouldSlide) {
			CGRect frame = self.frame;
			frame.origin.y = -kHBTSStatusBarHeight;
			self.frame = frame;
		}

		CGRect foregroundFrame = foregroundView.frame;
		foregroundFrame.origin.y = 0;
		foregroundFrame.size.height = kHBTSStatusBarHeight;
		foregroundView.frame = foregroundFrame;

		foregroundView.alpha = _foregroundViewAlpha;

		if (_shouldFade) {
			self.alpha = 0;
		}
	} completion:^(BOOL finished) {
		self.hidden = YES;

		CGRect frame = self.frame;
		frame.origin.y = 0;
		self.frame = frame;

		self.alpha = _foregroundViewAlpha;

		foregroundView.clipsToBounds = NO;

		_typeLabel.text = @"";
		_contactLabel.text = @"";

		self.hidden = YES;
		_isAnimating = NO;
		_isVisible = NO;

		if (IN_SPRINGBOARD) {
			notify_post("ws.hbang.typestatus/OverlayDidHide");
		}
	}];
}
@end
