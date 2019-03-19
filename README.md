# TypeStatus
iMessage typing and read receipt indicators for the iOS status bar. https://typestatus.com/

See also: [TypeStatus for Mac](https://github.com/hbang/TypeStatus-Mac).

## Creating a TypeStatus provider
Documentation is available at **[hbang.github.io/TypeStatus](https://hbang.github.io/TypeStatus/)**.

Make sure TypeStatus is already installed on your device.

Theos includes headers and a linkable framework for TypeStatus, so you don’t need to worry about copying files over from your device.

To develop a provider, create a bundle project. You can do this with a Theos makefile similar to this one:

```makefile
INSTALL_TARGET_PROCESSES = SpringBoard

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = MyAwesomeProvider
MyAwesomeProvider_FILES = XXXMyAwesomeProvider.m
MyAwesomeProvider_INSTALL_PATH = /Library/TypeStatus/Providers
MyAwesomeProvider_EXTRA_FRAMEWORKS = TypeStatusProvider

include $(THEOS_MAKE_PATH)/bundle.mk
```

A provider class subclasses from [HBTSProvider](https://hbang.github.io/TypeStatus/Classes/HBTSProvider.html). This must be the bundle’s principal class, defined in the Info.plist key `NSPrincipalClass`. Here is a simple example:

```objc
#import <TypeStatusProvider/TypeStatusProvider.h>

@interface XXXMyAwesomeProvider : HBLOProvider

@end
```

```objc
#import "XXXMyAwesomeProvider.h"

@implementation XXXMyAwesomeProvider

- (instancetype)init {
	self = [super init];

	if (self) {
		// do your thing to set up your notifications here…
	}

	return self;
}

- (void)receivedNotification:(NSNotification *)notification {
	// do your thing to get data from the notification here…
	NSString *sender = …;

	HBTSNotification *notification = [[HBTSNotification alloc] initWithType:HBTSMessageTypeTyping sender:sender iconName:nil];
	[self showNotification:notification];
}

@end
```

Or, alternatively, just create a stub class, and use [HBTSProviderController](https://hbang.github.io/TypeStatus/Classes/HBTSProviderController.html) to get an instance of your provider to cal `showNotification:` on. For instance:

```objc
#import "XXXMyAwesomeProvider.h"

@implementation XXXMyAwesomeProvider

@end
```

```logos
#import "XXXMyAwesomeProvider.h"
#import <TypeStatusProvider/TypeStatusProvider.h>

%hook XXXSomeClassInTheApp

- (void)messageReceived:(XXXMessage *)message {
	%orig;

	// do your thing to determine the message type and get data from the notification here…
	if (message.isTypingMessage) {
		NSString *sender = …;

		HBTSNotification *notification = [[HBTSNotification alloc] initWithType:HBTSMessageTypeTyping sender:sender iconName:nil];
		XXXMyAwesomeProvider *provider = (XXXMyAwesomeProvider *)[[HBTSProviderController sharedInstance] providerForAppIdentifier:@"com.example.awesomemessenger"];
		[provider showNotification:notification];
	}
}

%end
```

The `iconName` parameter can either be nil to use TypeStatus’s built-in icons for the predefined notification types, or the string of a [status bar icon](http://iphonedevwiki.net/index.php/Libstatusbar) name, installed identically to the way you would for a libstatusbar icon.

You must also add `ws.hbang.typestatus2` to the `Depends:` list in your control file. If TypeStatus isn’t present on the device, your binaries will fail to load. For example:

```
Depends: mobilesubstrate, something-else, some-other-package, ws.hbang.typestatus2 (>= 2.4)
```

You should specify the current version of TypeStatus as the minimum requirement, so you can guarantee all features you use are available.

## License
Licensed under the Apache License, version 2.0. Refer to [LICENSE.md](LICENSE.md).

See [About.plist](https://github.com/hbang/TypeStatus/blob/master/prefs/Resources/About.plist) and our [Translations](https://hashbang.productions/translations/) page for credits.
