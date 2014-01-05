#import "Global.h"

@interface HBTSStatusBarView : UIView

- (void)showWithType:(HBTSStatusBarType)type name:(NSString *)name timeout:(NSTimeInterval)timeout;
- (void)hide;

@property (nonatomic, retain) NSString *name;
@property HBTSStatusBarType type;

@property BOOL shouldSlide;
@property BOOL shouldFade;

@end
