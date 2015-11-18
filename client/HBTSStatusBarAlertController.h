#import <Foundation/NSXPCListener.h>

@class UIStatusBar;

@interface HBTSStatusBarAlertController : NSObject <NSXPCListenerDelegate, HBTSStatusBarAlertProtocol>

+ (instancetype)sharedInstance;

- (void)addStatusBar:(UIStatusBar *)statusBar;
- (void)removeStatusBar:(UIStatusBar *)statusBar;

- (void)showWithIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content;
- (void)hide;

- (void)displayCurrentAlertInStatusBar:(UIStatusBar *)statusBar animated:(BOOL)animated;

@end
