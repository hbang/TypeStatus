#import <Cephei/HBPreferences.h>

@class IMChat;

@interface HBTSConversationPreferences : NSObject

+ (BOOL)isAvailable;
+ (BOOL)shouldEnable;

- (NSDictionary *)dictionaryRepresentation;
- (void)registerPreferenceChangeBlock:(HBPreferencesChangeCallback)callback;

- (BOOL)typingNotificationsEnabledForChat:(IMChat *)chat;
- (BOOL)readReceiptsEnabledForChat:(IMChat *)chat;

- (BOOL)typingNotificationsEnabledForHandle:(NSString *)handle;
- (BOOL)readReceiptsEnabledForHandle:(NSString *)handle;

- (void)setTypingNotificationsEnabled:(BOOL)enabled forChat:(IMChat *)chat;
- (void)setReadReceiptsEnabled:(BOOL)enabled forChat:(IMChat *)chat;

- (void)setTypingNotificationsEnabled:(BOOL)enabled forHandle:(NSString *)handle;
- (void)setReadReceiptsEnabled:(BOOL)enabled forHandle:(NSString *)handle;

- (void)addHandle:(NSString *)handle;
- (void)removeHandle:(NSString *)handle;

@end
