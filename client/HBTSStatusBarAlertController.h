@class UIStatusBar, SBHomeGrabberView;

@interface HBTSStatusBarAlertController : NSObject

+ (BOOL)isHomeBarDevice;

+ (instancetype)sharedInstance;

- (void)addStatusBar:(UIStatusBar *)statusBar;
- (void)addHomeGrabber:(SBHomeGrabberView *)homeGrabber;

- (void)removeStatusBar:(UIStatusBar *)statusBar;
- (void)removeHomeGrabber:(SBHomeGrabberView *)homeGrabber;

- (void)displayCurrentAlertInStatusBar:(UIStatusBar *)statusBar animated:(BOOL)animated;
- (void)displayCurrentAlertInHomeGrabber:(SBHomeGrabberView *)homeGrabber animated:(BOOL)animated;

@end
