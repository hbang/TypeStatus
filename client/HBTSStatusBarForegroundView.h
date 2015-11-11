#import <UIKit/UIStatusBarForegroundView.h>

@interface HBTSStatusBarForegroundView : UIStatusBarForegroundView

@property (nonatomic, retain) UIStatusBarForegroundView *statusBarView;

- (void)setIconName:(NSString *)iconName title:(NSString *)title content:(NSString *)content;

@end
