#import "Global.h"

@interface HBTSStatusBarView : UIView {
	UIView *_containerView;
	UILabel *_typeLabel;
	UILabel *_contactLabel;
	UIImageView *_iconImageView;
	BOOL _shouldSlide;
	BOOL _shouldFade;
	BOOL _isAnimating;
	NSTimer *_timer;
	HBTSStatusBarType _type;
}

- (void)showWithTimeout:(double)timeout;
- (void)hide;

@property (nonatomic, retain) NSString *string;
@property BOOL shouldSlide;
@property BOOL shouldFade;
@property HBTSStatusBarType type;
@end
