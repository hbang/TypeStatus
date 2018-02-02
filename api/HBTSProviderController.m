#import "HBTSProviderController+Private.h"
#import "HBTSIMessageProvider.h"
#import "HBTSPreferences.h"
#import "HBTSProvider.h"
#import <MobileCoreServices/LSApplicationProxy.h>

static NSString *const kHBTSProvidersURL = @"file:///Library/TypeStatus/Providers/";

@implementation HBTSProviderController {
	dispatch_queue_t _queue;

	NSMutableSet <HBTSProvider *> *_providers;
	NSMutableSet <NSString *> *_appsRequiringBackgroundSupport;
}

+ (instancetype)sharedInstance {
	static HBTSProviderController *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

#pragma mark - Initialization

- (instancetype)init {
	self = [super init];

	if (self) {
		// we use a serial queue to (a) do our heavy work without blocking the main thread, and
		// (b) kinda-sorta act as a lock, avoiding potential racing
		_queue = dispatch_queue_create("ws.hbang.typestatusplus.providercontrollerqueue", DISPATCH_QUEUE_SERIAL);

		_providers = [NSMutableSet set];
		_appsRequiringBackgroundSupport = [NSMutableSet set];

		// add our hardcoded imessage provider
		[_providers addObject:[[HBTSIMessageProvider alloc] init]];

		// then load the rest of them
		[self _loadProvidersWithCompletion:nil];
	}

	return self;
}

#pragma mark - Loading providers

- (void)_loadProvidersWithCompletion:(HBTSLoadProvidersCompletion)completion {
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		dispatch_async(_queue, ^{
			HBLogInfo(@"loading providers");

			NSURL *providersURL = [NSURL URLWithString:kHBTSProvidersURL].URLByResolvingSymlinksInPath;

			NSError *error = nil;
			NSArray <NSURL *> *contents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:providersURL includingPropertiesForKeys:nil options:kNilOptions error:&error];

			if (error) {
				HBLogError(@"failed to access handler directory %@: %@", kHBTSProvidersURL, error.localizedDescription);
				return;
			}

			// anything other than springboard and preferences can be a provider app
			BOOL inApp = !IN_SPRINGBOARD && ![[NSBundle mainBundle].bundleIdentifier isEqualToString:@"com.apple.Preferences"];

			for (NSURL *directory in contents) {
				NSString *baseName = directory.pathComponents.lastObject;

				// skip anything not ending in .bundle
				if (![baseName hasSuffix:@".bundle"]) {
					continue;
				}

				HBLogInfo(@"loading provider %@", baseName);

				NSBundle *bundle = [NSBundle bundleWithURL:directory];

				if (!bundle) {
					HBLogError(@" --> failed to instantiate the bundle!");
					continue;
				}

				id identifier = bundle.infoDictionary[kHBTSApplicationBundleIdentifierKey];

				if (!identifier) {
					HBLogError(@" --> no app identifier set!");
					continue;
				}

				NSArray <NSString *> *identifiers;

				if ([identifier isKindOfClass:NSString.class]) {
					identifiers = @[ identifier ];
				} else if ([identifier isKindOfClass:NSArray.class]) {
					identifiers = identifier;
				} else {
					HBLogError(@" --> invalid value provided for %@", kHBTSApplicationBundleIdentifierKey);
					continue;
				}

				NSString *appIdentifier;

				if (inApp) {
					if (![identifiers containsObject:[NSBundle mainBundle].bundleIdentifier]) {
						HBLogDebug(@" --> not in the right app. not loading");
						continue;
					}

					appIdentifier = [NSBundle mainBundle].bundleIdentifier;
				} else {
					NSMutableArray <NSString *> *knownIdentifiers = [NSMutableArray array];

					for (NSString *identifier in identifiers) {
						LSApplicationProxy *proxy = [LSApplicationProxy applicationProxyForIdentifier:identifier];

						if (proxy.isInstalled) {
							HBLogDebug(@" --> provider app %@ is installed", identifier);
							[knownIdentifiers addObject:identifier];
						}
					}

					// if the app isn’t installed, don’t bother loading
					if (knownIdentifiers.count == 0) {
						HBLogDebug(@" --> no supported apps installed. not loading");
						continue;
					}

					appIdentifier = knownIdentifiers[0];
				}

				if (![bundle load]) {
					HBLogError(@" --> bundle failed to load!");
					continue;
				}

				if (!bundle.principalClass) {
					HBLogError(@" --> no principal class set!");
					continue;
				}

				if (((NSNumber *)bundle.infoDictionary[kHBTSKeepApplicationAliveKey]).boolValue) {
					[_appsRequiringBackgroundSupport addObjectsFromArray:identifiers];
				}

				HBTSProvider *provider = [[bundle.principalClass alloc] init];
				provider.appIdentifier = appIdentifier;

				if (!provider) {
					HBLogError(@" --> failed to initialise provider class %@", identifier);
					continue;
				}

				[_providers addObject:provider];
			}
		});
	});

	// if we have a completion, add another block to our queue that will call the completion on the
	// main thread. bit convoluted i know, but it makes sense considering the queue lock pattern
	if (completion) {
		dispatch_async(_queue, ^{
			dispatch_async(dispatch_get_main_queue(), completion);
		});
	}
}

#pragma mark - Properties

- (NSSet *)providers {
	return _providers;
}

#pragma mark - Backgrounding

- (NSSet *)appsRequiringBackgroundSupport {
	return _appsRequiringBackgroundSupport;
}

- (BOOL)doesApplicationIdentifierRequireBackgrounding:(NSString *)appIdentifier {
	return [_appsRequiringBackgroundSupport containsObject:appIdentifier];
}

#pragma mark - Preferences

- (HBTSProvider *)providerForAppIdentifier:(NSString *)appIdentifier {
	for (HBTSProvider *provider in _providers) {
		if ([provider.appIdentifier isEqualToString:appIdentifier]) {
			return provider;
		}
	}

	return nil;
}

@end
