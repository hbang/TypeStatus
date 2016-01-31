#import <UIKit/UIStatusBarForegroundView.h>

@interface HBTSStatusBarForegroundView : UIStatusBarForegroundView

@property (nonatomic, retain) UIStatusBarForegroundView *statusBarView;

- (void)setIconName:(NSString *)iconName text:(NSString *)text boldRange:(NSRange)boldRange;

@end
