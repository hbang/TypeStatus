@class CKConversation;

@interface HBTSConversationPreferences : NSObject

- (BOOL)typingNotificationsEnabledForConversation:(CKConversation *)conversation;
- (BOOL)readReceiptsEnabledForConversation:(CKConversation *)conversation;

- (void)setTypingNotificationsEnabled:(BOOL)enabled forConversation:(CKConversation *)conversation;
- (void)setReadReceiptsEnabled:(BOOL)enabled forConversation:(CKConversation *)conversation;

@end
