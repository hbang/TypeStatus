NS_ASSUME_NONNULL_BEGIN

/// The Info.plist key used to retrieve the app bundle identifier. Value may be a string or array
/// of strings.
static NSString *const kHBTSApplicationBundleIdentifierKey = @"HBTSApplicationBundleIdentifier";

/// The Info.plist key used to determine whether the specified app must be kept alive in the
/// background to receive events to be displayed as a TypeStatus notification.
static NSString *const kHBTSKeepApplicationAliveKey = @"HBTSKeepApplicationAlive";

@class HBTSProvider;

/// HBTSProviderController manages providers and provides assorted functions for providers to
/// make use of.
@interface HBTSProviderController : NSObject

/// Returns the singleton instance of this class.
///
/// @return The singleton instance of this class.
+ (instancetype)sharedInstance;

/// All instances of HBTSProvider that are known in this process.
///
/// In SpringBoard and Preferences, this will be fully populated with all provider bundles found in
/// /Library/TypeStatus/Providers. In apps, this will only contain provider(s) that are loaded into
/// the app.
///
/// @see providerForAppIdentifier:
@property (nonatomic, retain, readonly) NSSet *providers;

/// Retrieves the provider corresponding to the specified app bundle identifier.
///
/// @param appIdentifier The bundle identifier of the app to retrieve the corresponding provider for.
/// @return The HBTSProvider corresponding to the provider, or nil if it doesn't exist or the
/// bundle is not loaded in this process.
/// @see providers
- (HBTSProvider *)providerForAppIdentifier:(NSString *)appIdentifier;

/// Indicates whether the specified app bundle identifier is being kept active in the background by
/// a TypeStatus Plus provider.
///
/// @param bundleIdentifier The bundle identifier to check.
/// @return Whether the app is being kept active in the background.
- (BOOL)doesApplicationIdentifierRequireBackgrounding:(NSString *)bundleIdentifier;

@end

NS_ASSUME_NONNULL_END
