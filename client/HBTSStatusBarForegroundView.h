#import <UIKit/UIStatusBarForegroundView.h>

@interface HBTSStatusBarForegroundView : UIStatusBarForegroundView

@property (nonatomic, retain) UIStatusBarForegroundView *statusBarView;

- (void)setType:(HBTSStatusBarType)type contactName:(NSString *)contactName;

@end
