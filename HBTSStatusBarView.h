#import "Global.h"

@interface HBTSStatusBarView : UIView {
	UIView *_containerView;
	UILabel *_typeLabel;
	UILabel *_contactLabel;
	UIImageView *_iconImageView;
	BOOL _shouldSlide;
	BOOL _shouldFade;
	BOOL _isAnimating;
	BOOL _isVisible;
	NSTimer *_timer;
	HBTSStatusBarType _type;
	float _foregroundViewAlpha;
}

- (void)showWithTimeout:(double)timeout;
- (void)hide;

@property (nonatomic, retain) NSString *string;
@property BOOL shouldSlide;
@property BOOL shouldFade;
@property HBTSStatusBarType type;
@end
