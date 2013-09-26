#import "Global.h"
#import <BulletinBoard/BBDataProvider.h>

@interface HBTSBulletinProvider : NSObject <BBDataProvider>

+ (instancetype)sharedInstance;
- (void)showBulletinOfType:(HBTSStatusBarType)type string:(NSString *)string;

@end
