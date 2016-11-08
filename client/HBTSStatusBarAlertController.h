@class UIStatusBar;

@interface HBTSStatusBarAlertController : NSObject

+ (instancetype)sharedInstance;

- (void)addStatusBar:(UIStatusBar *)statusBar;
- (void)removeStatusBar:(UIStatusBar *)statusBar;

- (void)displayCurrentAlertInStatusBar:(UIStatusBar *)statusBar animated:(BOOL)animated;

@end
