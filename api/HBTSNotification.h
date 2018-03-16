@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/// Notification types natively supported by TypeStatus.
///
/// @see -[HBTSNotification initWithType:sender:iconName:]
typedef NS_ENUM(NSUInteger, HBTSMessageType) {
	HBTSMessageTypeTyping,
	HBTSMessageTypeTypingEnded,
	HBTSMessageTypeReadReceipt,
	HBTSMessageTypeSendingFile
};

/// HBTSNotification represents a notification for TypeStatus to display. To post the notification to
/// be displayed, pass it to -[HBTSProvider showNotification:].
@interface HBTSNotification : NSObject

/// Initialises and returns an HBTSNotification with the type, sender, and icon name already set.
///
/// @param type The type of notification. This is used to determine the content string to use.
/// @param sender The name of the sending person.
/// @param iconName The icon to display in the status bar. Refer to statusBarIconName.
/// @return A configured instance of HBTSNotification.
/// @see statusBarIconName
- (instancetype)initWithType:(HBTSMessageType)type sender:(NSString *)sender iconName:(NSString *)iconName;

/// Initialises and returns an HBTSNotification with the provided serialized notification dictionary.
/// Used by TypeStatus Plus when internally deserializing a notification to be displayed.
///
/// @param dictionary The serialized notification dictionary.
/// @return An instance of HBTSNotification populated with the deserialized parameters.
/// @see dictionaryRepresentation
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

/// Serializes the notification into a dictionary. Used by TypeStatus Plus internally to prepare the
/// notification to be sent to other processes.
///
/// @see initWithDictionary:
- (NSDictionary *)dictionaryRepresentation;

/// The bundle identifier of the app this notification originates from, or nil to have this property
/// automatically determined by TypeStatus based on the provider's matching app identifier.
///
/// @see -[HBTSProvider appIdentifier]
@property (nonatomic, copy, nullable) NSString *sourceBundleID;

/// The content of the notification, to be displayed to the user.
@property (nonatomic, copy, nullable) NSString *content;

/// The portion of the content that should be displayed in bold font. This is usually the name of
/// the sending person.
@property (nonatomic) NSRange boldRange;

/// The date the notification originated. Displayed in Notification Center bulletins.
///
/// The default value is the timestamp that the HBTSNotification was initialised.
@property (nonatomic, copy) NSDate *date;

/// The icon to display in the status bar, or nil to not display an icon.
///
/// The icon must be installed to /System/Library/Frameworks/UIKit.framework.
@property (nonatomic, copy, nullable) NSString *statusBarIconName;

/// A URL to open when the user taps the notification, or nil to launch the app indicated by the
/// sourceBundleID property.
@property (nonatomic, copy, nullable) NSURL *actionURL;

@end

NS_ASSUME_NONNULL_END
