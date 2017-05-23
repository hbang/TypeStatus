#import "HBTSContactHelper.h"
#import "HBTSPreferences.h"
#import <ChatKit/CKEntity.h>
#import <ChatKit/CKDNDList.h>
#import <Contacts/Contacts.h>
#import <Contacts/CN.h>
#import <Contacts/CNContact+Private.h>
#import <Contacts/CNContactFormatter+Private.h>
#import <Contacts/CNEmailAddressContactPredicate.h>
#import <Contacts/CNPhoneNumberContactPredicate.h>
#import <Contacts/CNPropertyDescription.h>
#import <IMCore/IMHandle.h>

HBTSPreferences *preferences;

@implementation HBTSContactHelper

+ (BOOL)isHandleMuted:(NSString *)handle {
	// if ignore DND is enabled and the feature is available (iOS 8.2+)
	if (preferences.ignoreDNDSenders && %c(CKDNDList)) {
		// get the unmute date, which is probably distantFuture
		NSDate *unmuteDate = [(CKDNDList *)[%c(CKDNDList) sharedList] unmuteDateForIdentifier:handle];

		// if the date is non-nil and still in the future, the handle is muted
		return unmuteDate && [unmuteDate compare:[NSDate date]] == NSOrderedDescending;
	}

	return NO;
}

+ (CNContact *)_contactForHandle:(NSString *)handle {
	static CNContactStore *contactStore;
	static NSArray *keysToFetch;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		contactStore = [[CNContactStore alloc] init];

		// yeah, it’s a real class. way to lazy out
		NSArray *descriptions = [%c(CN) allNameComponentRelatedProperties];
		NSMutableArray *keys = [NSMutableArray array];

		for (CNPropertyDescription *description in descriptions) {
			[keys addObject:description.key];
		}

		keysToFetch = [keys copy];
	});

	// search for contacts with that email address
	NSError *error = nil;
	NSArray <CNContact *> *contacts = [contactStore unifiedContactsMatchingPredicate:[CNContact predicateForContactMatchingEmailAddress:handle] keysToFetch:keysToFetch error:&error];

	if (error || contacts.count == 0) {
		// try with the phone number
		contacts = [contactStore unifiedContactsMatchingPredicate:[CNContact predicateForContactMatchingPhoneNumber:[CNPhoneNumber phoneNumberWithStringValue:handle]] keysToFetch:keysToFetch error:&error];

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
	} else if (%c(CNContact) && !shortName) {
		// ios 9+: use Contacts.framework because Contacts.framework is awesome
		CNContact *contact = [self _contactForHandle:handle];

		// contact doesn’t exist? return the handle
		if (!contact) {
			return handle;
		}

		// get a contact formatter and use it to return the name
		CNContactFormatter *contactFormatter = [[CNContactFormatter alloc] init];
		return [contactFormatter stringFromContact:contact];
	} else {
		static NSString *buddyNameString;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken, ^{
			NSBundle *imCoreBundle = [NSBundle bundleWithPath:@"/System/Library/PrivateFrameworks/IMCore.framework"];
			buddyNameString = [imCoreBundle localizedStringForKey:@"Buddy Name" value:@"" table:@"IMCoreLocalizable"];
		});

		CKEntity *entity = [%c(CKEntity) copyEntityForAddressString:handle];
		NSString *result = nil;

		// if we didn’t get anything, just fall back to the handle. if it’s a person, return their
		// display name. if it’s a business, return the entity name. if none of these are available,
		// fall back to the handle
		if (!entity) {
			result = nil;
		} else if (entity.handle.person && entity.handle._displayNameWithAbbreviation) {
			result = entity.handle._displayNameWithAbbreviation;
		} else if (entity.name) {
			result = entity.name;
		}

		// if our result is non-nil and not equal to “Buddy Name”, return it. otherwise, use the handle
		return result && ![result isEqualToString:buddyNameString] ? result : handle;
	}
}

@end
