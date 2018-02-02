#import "HBTSNotification.h"

NS_ASSUME_NONNULL_BEGIN

/// HBTSProvider is the class used to represent a provider. You should subclass HBTSProvider
/// in your provider bundle, and then set it as the principal class in the Info.plist. A provider
/// class is required even if it doesn't implement any methods on its own.
@interface HBTSProvider : NSObject

/// The name of the provider, to display in the TypeStatus Plus settings. This typically does not
/// need to be set, and will be populated with the app name corresponding to appIdentifier.
///
/// @see appIdentifier
@property (nonatomic, retain) NSString *name;

/// The bundle identifier of the app corresponding to this provider. This typically does not need to
/// be set, and will be populated by the `HBTSApplicationBundleIdentifier` value provided in the
/// provider's Info.plist.
@property (nonatomic, retain, nullable) NSString *appIdentifier;

/// Custom Preferences list controller bundle.
///
/// If nil, a switch will be shown in Settings, and enabled/disabled state is handled by TypeStatus
/// Plus. Otherwise, tapping the cell will push your list controller, and enabled state is handled
/// by your code.
///
/// @see preferencesClass
/// @see isEnabled
@property (nonatomic, retain, nullable) NSBundle *preferencesBundle;

/// Custom Preferences list controller class.
///
/// Refer to preferencesBundle for more details. If this is nil, the principal class of the bundle
/// will be used.
///
/// @see preferencesBundle
/// @see isEnabled
@property (nonatomic, retain, nullable) NSString *preferencesClass;

/// Indicates whether the user has enabled the provider.
///
/// If TypeStatus Plus is disabled by the user, this property is set to `NO`. If a custom preference
/// list controller is used, this property is set to `YES` and you are expected to handle enabled
/// state separately from TypeStatus Plus. Otherwise, this property is the enabled state of this
/// provider as configured by the user.
///
/// @return As described above.
@property (nonatomic, assign, readonly) BOOL isEnabled;

/// Post a notification to be displayed to the user.
///
/// @param notification An HBTSNotification to be displayed.
/// @see HBTSNotification
- (void)showNotification:(HBTSNotification *)notification;

/// Hide the currently displayed TypeStatus notification, if any.
///
/// This hides any notification, including ones that originated from another provider.
- (void)hideNotification;

@end

NS_ASSUME_NONNULL_END
