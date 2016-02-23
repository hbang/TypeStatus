@class CKConversation;

@interface HBTSConversationPreferences : NSObject

+ (BOOL)isAvailable;
+ (BOOL)shouldEnable;

- (BOOL)typingNotificationsEnabledForConversation:(CKConversation *)conversation;
- (BOOL)readReceiptsEnabledForConversation:(CKConversation *)conversation;

- (BOOL)typingNotificationsEnabledForHandle:(NSString *)handle;
- (BOOL)readReceiptsEnabledForHandle:(NSString *)handle;

- (void)setTypingNotificationsEnabled:(BOOL)enabled forConversation:(CKConversation *)conversation;
- (void)setReadReceiptsEnabled:(BOOL)enabled forConversation:(CKConversation *)conversation;

@end
