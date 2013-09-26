#import "Global.h"
#import <BulletinBoard/BBDataProvider.h>

@interface HBTSBulletinProvider : NSObject <BBDataProvider>

+ (void)showBulletinOfType:(HBTSOverlayType)type string:(NSString *)string;

@end
