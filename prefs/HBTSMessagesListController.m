#import "HBTSMessagesListController.h"

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
	ABPeoplePickerNavigationController *pickerController = [[ABPeoplePickerNavigationController alloc] init];
	pickerController.peoplePickerDelegate = self;
	pickerController.modalPresentationStyle = UIModalPresentationFormSheet;
	[self.navigationController presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark - ABPeoplePickerNavigationControllerDelegate

- (void)peoplePickerNavigationController:(ABPeoplePickerNavigationController *)peoplePicker didSelectPerson:(ABRecordRef)person {
	HBLogDebug(@"peoplePickerNavigationController:%@ didSelectPerson:%@",peoplePicker,person);
}

@end
