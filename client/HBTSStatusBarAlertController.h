@class UIStatusBar;

@interface HBTSStatusBarAlertController : NSObject

+ (instancetype)sharedInstance;

- (void)addStatusBar:(UIStatusBar *)statusBar;
- (void)removeStatusBar:(UIStatusBar *)statusBar;

- (void)showWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content;
- (void)showWithIconName:(NSString *)iconName text:(NSString *)text boldRange:(NSRange)boldRange;
- (void)hide;

- (void)displayCurrentAlertInStatusBar:(UIStatusBar *)statusBar animated:(BOOL)animated;

@end
