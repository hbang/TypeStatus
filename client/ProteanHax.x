#include <dlfcn.h>

@class UIStatusBarItem;

// protean crashes on this method. probably because we use a nil status bar
// item, which isn't surprising. it hasn't been updated in a while so this is a
// workaround until it does get updated

%hook Protean

+ (BOOL)canHandleTapForItem:(UIStatusBarItem *)item {
	// if the item is nil, just return NO
	if (!item) {
		return NO;
	}

	return %orig;
}

%end

%ctor {
	// if protean is installed, load it, then execute the hooks
	if ([[NSFileManager defaultManager] fileExistsAtPath:@"/Library/MobileSubstrate/DynamicLibraries/Protean.dylib"]) {
		dlopen("/Library/MobileSubstrate/DynamicLibraries/Protean.dylib", RTLD_NOW);
		%init;
	}
}
