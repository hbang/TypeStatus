#import "HBTSStatusBarOverlayWindow.h"
#import <UIKit/UIImage+Private.h>

@implementation HBTSStatusBarOverlayWindow
@synthesize shouldSlide = _shouldSlide, shouldFade = _shouldFade;

- (id)init {
	self = [super init];

	if (self) {
		self.windowLevel = UIWindowLevelStatusBar + 1.f;
		self.hidden = NO;
		self.userInteractionEnabled = NO;
		self.rootViewController = [[UIViewController alloc] init];
		self.rootViewController.view.frame = CGRectMake(0, 0, 0, 20.f);

		_containerContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 20.f)];
		_containerContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		_containerContainerView.hidden = YES;
		[self.rootViewController.view addSubview:_containerContainerView];

		UIImageView *backgroundImageView = [[[UIImageView alloc] initWithImage:[[UIImage kitImageNamed:@"Black_Base.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2.f, 0, 2.f)]] autorelease];
		backgroundImageView.frame = _containerContainerView.frame;
		backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[_containerContainerView addSubview:backgroundImageView];

		_containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, _containerContainerView.frame.size.height)];
		_containerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		[_containerContainerView addSubview:_containerView];

		UIImageView *iconImageView = [[[UIImageView alloc] initWithImage:[UIImage kitImageNamed:@"WhiteOnBlackEtch_TypeStatus"]] autorelease];
		iconImageView.center = CGPointMake(iconImageView.center.x, _containerContainerView.frame.size.height / 2.f);
		iconImageView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
		[_containerView addSubview:iconImageView];

		_iconWidth = iconImageView.frame.size.width;

		_label = [[UILabel alloc] initWithFrame:CGRectMake(_iconWidth + 4.f, 0, 0, _containerContainerView.frame.size.height)];
		_label.font = [UIFont boldSystemFontOfSize:14.f];
		_label.backgroundColor = [UIColor clearColor];
		_label.textColor = [UIColor whiteColor];
		_label.shadowOffset = CGSizeMake(0, 1.f);
		_label.shadowColor = [UIColor blackColor];
		[_containerView addSubview:_label];
	}

	return self;
}

- (NSString *)string {
	return _label.text;
}

- (void)setString:(NSString *)string {
	if (string) {
		_label.text = string ?: @"";

		CGRect labelFrame = _label.frame;
		labelFrame.size.width = [_label.text sizeWithFont:_label.font constrainedToSize:_containerContainerView.frame.size lineBreakMode:UILineBreakModeTailTruncation].width;
		_label.frame = labelFrame;

		CGRect containerFrame = _containerView.frame;
		containerFrame.size.width = _iconWidth + 4.f + labelFrame.size.width;
		_containerView.frame = containerFrame;

		_containerView.center = CGPointMake(_containerContainerView.frame.size.width / 2.f, _containerView.center.y);
	} else {
		[self hide];
	}
}

- (void)showWithTimeout:(double)timeout {
	if (_timer || _isAnimating) {
		return;
	}

	_isAnimating = YES;

	if (_shouldSlide) {
		CGRect frame = _containerContainerView.frame;
		frame.origin.y = -frame.size.height;
		_containerContainerView.frame = frame;
	}

	_containerContainerView.alpha = _shouldFade ? 0 : 1;
	_containerContainerView.hidden = NO;

	[UIView animateWithDuration:0.3f animations:^{
		if (_shouldSlide) {
			CGRect frame = _containerContainerView.frame;
			frame.origin.y = 0;
			_containerContainerView.frame = frame;
		}

		_containerContainerView.alpha = 1;
	} completion:^(BOOL finished) {
		_isAnimating = NO;
		_timer = [[NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(hide) userInfo:nil repeats:NO] retain];
	}];
}

- (void)hide {
	if (!_timer || _isAnimating) {
		return;
	}

	_isAnimating = YES;

	[_timer invalidate];
	[_timer release];
	_timer = nil;

	[UIView animateWithDuration:0.3f animations:^{
		if (_shouldSlide) {
			CGRect frame = _containerContainerView.frame;
			frame.origin.y = -frame.size.height;
			_containerContainerView.frame = frame;
		}

		if (_shouldFade) {
			_containerContainerView.alpha = 0;
		}
	} completion:^(BOOL finished) {
		_containerContainerView.hidden = YES;

		CGRect frame = _containerContainerView.frame;
		frame.origin.y = 0;
		_containerContainerView.frame = frame;

		_containerContainerView.alpha = 1;

		_label.text = @"";

		_isAnimating = NO;
	}];
}
@end
