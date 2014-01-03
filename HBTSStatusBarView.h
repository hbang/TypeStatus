#import "Global.h"

@interface HBTSStatusBarView : UIView

- (void)showWithTimeout:(double)timeout;
- (void)hide;

@property (nonatomic, retain) NSString *string;
@property BOOL shouldSlide;
@property BOOL shouldFade;
@property HBTSStatusBarType type;

@end
