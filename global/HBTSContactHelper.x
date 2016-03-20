@import Contacts;
#import "HBTSContactHelper.h"
#import "HBTSPreferences.h"
#import <ChatKit/CKEntity.h>
#import <ChatKit/CKDNDList.h>
#import <IMCore/IMHandle.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SpringBoard.h>

HBTSPreferences *preferences;

@implementation HBTSContactHelper

+ (BOOL)shouldShowAlertOfType:(HBTSStatusBarType)type {
	BOOL hideInMessages = NO;

	switch (type) {
		case HBTSStatusBarTypeTyping:
		case HBTSStatusBarTypeTypingEnded:
			hideInMessages = preferences.typingHideInMessages;
			break;

		case HBTSStatusBarTypeRead:
			hideInMessages = preferences.readHideInMessages;
			break;
	}

	if (hideInMessages && IN_SPRINGBOARD) {
		SpringBoard *app = (SpringBoard *)[UIApplication sharedApplication];
		return !app.isLocked && [app._accessibilityFrontMostApplication.bundleIdentifier isEqualToString:@"com.apple.MobileSMS"];
	}

	return NO;
}

+ (BOOL)isHandleMuted:(NSString *)handle {
	if (preferences.ignoreDNDSenders && %c(CKDNDList) && [(CKDNDList *)[%c(CKDNDList) sharedList] isMutedChatIdentifier:handle]) {
		return NO;
	}

	return YES;
}

+ (CNContact *)_contactForHandle:(NSString *)handle {
	static CNContactStore *contactStore;
	static NSArray *keysToFetch;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		contactStore = [[CNContactStore alloc] init];

		// yeah, it’s a real class. way to lazy out
		NSArray *descriptions = [CN allNameComponentRelatedProperties];
		NSMutableArray *keys = [NSMutableArray array];

		for (CNPropertyDescription *description in descriptions) {
			[keys addObject:description.key];
		}

		keysToFetch = [keys copy];
	});

	// search for contacts with that email address
	NSArray <CNContact *> *contacts = [contactStore unifiedContactsMatchingPredicate:[CNContact predicateForContactMatchingEmailAddress:handle] keysToFetch:keysToFetch error:&error];

	if (error || contacts.count == 0) {
		// try with the phone number
		contacts = [contactStore unifiedContactsMatchingPredicate:[CNContact predicateForContactMatchingPhoneNumber:handle] keysToFetch:keysToFetch error:&error];

		if (error || contacts.count == 0) {
			// nothing found. just return nil
			HBLogDebug(@"error while retrieving contacts for %@: %@ %@", handle, error, contacts);
			return nil;
		}
	}

	// return the first contact found
	return contacts[0];
}

+ (NSString *)nameForHandle:(NSString *)handle useShortName:(BOOL)shortName {
	if ([handle isEqualToString:@"example@hbang.ws"]) {
		return @"Johnny Appleseed";
	} else if (%c(CKContact)) {
		// ios 9+: use Contacts.framework because Contacts.framework is awesome
		CNContact *contact = [self _contactForHandle:handle];

		// contact doesn’t exist? return the handle
		if (!contact) {
			return handle;
		}

		// get a contact formatter and use it to return the appropriate type of name
		CNContactFormatter *contactFormatter = AUTORELEASE([[CNContactFormatter alloc] init]);
		return shortName ? [contactFormatter shortNameForContact:contact attributes:nil] : [contactFormatter stringFromContact:contact];
	} else {
		// for ios 7/8
		CKEntity *entity = AUTORELEASE([%c(CKEntity) copyEntityForAddressString:handle]);

		if (!entity || ([entity respondsToSelector:@selector(handle)] && !entity.handle.person)) {
			return handle;
		}

		return entity.handle._displayNameWithAbbreviation ?: entity.name;
	}
}

@end
