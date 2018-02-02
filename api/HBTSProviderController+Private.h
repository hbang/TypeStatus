#import "HBTSProviderController.h"

typedef void (^HBTSLoadProvidersCompletion)();

@interface HBTSProviderController (Private)

- (void)_loadProvidersWithCompletion:(HBTSLoadProvidersCompletion)completion;

@property (nonatomic, retain, readonly) NSSet *appsRequiringBackgroundSupport;

@end
