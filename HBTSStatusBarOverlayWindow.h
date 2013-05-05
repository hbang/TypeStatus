@interface HBTSStatusBarOverlayWindow : UIWindow {
	UILabel *_label;
	UIView *_containerView;
	UIView *_containerContainerView;
	float _iconWidth;
	BOOL _shouldSlide;
	BOOL _shouldFade;
	BOOL _isAnimating;
	NSTimer *_timer;
}

- (void)showWithTimeout:(double)timeout;
- (void)hide;

@property (nonatomic, retain) NSString *string;
@property (nonatomic, retain) UIView *containerContainerView;
@property BOOL shouldSlide;
@property BOOL shouldFade;
@end
