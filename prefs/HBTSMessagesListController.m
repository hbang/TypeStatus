#import "HBTSMessagesListController.h"
#import "../global/HBTSConversationPreferences.h"
#import <Preferences/PSSpecifier.h>

@implementation HBTSMessagesListController

+ (NSString *)hb_specifierPlist {
	return @"Messages";
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self _disableIfNeeded];
	[self _insertPeople];
}

- (void)reloadSpecifiers {
	[super reloadSpecifiers];
	[self _disableIfNeeded];
	[self _insertPeople];
}

#pragma mark - Setup

- (void)_disableIfNeeded {
	// if conversation prefs are available
	if ([HBTSConversationPreferences isAvailable]) {
		// remove the not available text
		[self removeSpecifierID:@"NotAvailable"];
	} else {
		// loop over all specifiers
		for (PSSpecifier *specifier in self.specifiers) {
			// disable them all
			specifier.properties[PSEnabledKey] = @NO;
		}
	}
}

- (void)_insertPeople {
	// [self insertSpecifiers:specifiers ] ...
	// ConversationPrefsList
}

#pragma mark - Callbacks

- (void)addPerson {
	// TODO: can this be autoreleased?
	CNContactPickerViewController *pickerController = [[[CNContactPickerViewController alloc] init] autorelease];
	pickerController.delegate = self;
	pickerController.predicateForEnablingContact = [NSPredicate predicateWithFormat:@"phoneNumbers.@count > 0 OR emailAddresses.@count > 0"];
	pickerController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self.navigationController presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark - CNContactPickerDelegate

- (void)contactPicker:(CNContactPickerViewController *)contactPicker didSelectContact:(CNContact *)contact {
	NSMutableArray *values = [NSMutableArray array];

	for (CNLabeledValue<CNPhoneNumber *> *value in contact.phoneNumbers) {
		[values addObject:value.value.stringValue];
	}

	for (CNLabeledValue<NSString *> *value in contact.emailAddresses) {
		[values addObject:value.value];
	}
}

@end
