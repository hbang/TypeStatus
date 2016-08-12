@interface HBTSContactHelper : NSObject

+ (BOOL)isHandleMuted:(NSString *)handle;

+ (NSString *)nameForHandle:(NSString *)handle useShortName:(BOOL)shortName;

@end
