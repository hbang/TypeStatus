@class CKConversation;

@interface HBTSConversationPreferences : NSObject

+ (BOOL)isAvailable;
+ (BOOL)shouldEnable;

- (NSDictionary *)dictionaryRepresentation;

- (BOOL)typingNotificationsEnabledForConversation:(CKConversation *)conversation;
- (BOOL)readReceiptsEnabledForConversation:(CKConversation *)conversation;

- (BOOL)typingNotificationsEnabledForHandle:(NSString *)handle;
- (BOOL)readReceiptsEnabledForHandle:(NSString *)handle;

- (void)setTypingNotificationsEnabled:(BOOL)enabled forConversation:(CKConversation *)conversation;
- (void)setReadReceiptsEnabled:(BOOL)enabled forConversation:(CKConversation *)conversation;

- (void)setTypingNotificationsEnabled:(BOOL)enabled forHandle:(NSString *)handle;
- (void)setReadReceiptsEnabled:(BOOL)enabled forHandle:(NSString *)handle;

- (void)addHandle:(NSString *)handle;
- (void)removeHandle:(NSString *)handle;

@end
