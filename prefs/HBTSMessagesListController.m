#import "HBTSMessagesListController.h"
#import "HBTSMessagesPersonListController.h"
#import "../global/HBTSConversationPreferences.h"
#import <Preferences/PSSpecifier.h>

@implementation HBTSMessagesListController {
	UIBarButtonItem *_editBarButtonItem;
	UIBarButtonItem *_doneBarButtonItem;

	HBTSConversationPreferences *_preferences;
	NSArray *_items;
}

+ (NSString *)hb_specifierPlist {
	return @"Messages";
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	_editBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(_editTapped:)];
	_doneBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(_editTapped:)];

	self.navigationItem.rightBarButtonItem = _editBarButtonItem;

	_preferences = [[HBTSConversationPreferences alloc] init];

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
	NSMutableArray *items = [NSMutableArray array];
	NSMutableArray *newSpecifiers = [NSMutableArray array];

	// loop over all the preference keys
	for (NSString *key in _preferences.dictionaryRepresentation.allKeys) {
		// get the handle from the key name
		NSString *handle = [key substringToIndex:[key rangeOfString:@"-"].location];

		// if we haven’t yet seen this handle, add it
		if (![items containsObject:handle]) {
			[items addObject:handle];
		}
	}

	// loop over the handles we got
	for (NSString *handle in items) {
		// create a specifier for it
		PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:handle target:self set:nil get:nil detail:HBTSMessagesPersonListController.class cell:PSLinkCell edit:Nil];

		// add it to the array
		[newSpecifiers addObject:specifier];
	}

	// grab a permanent immutable copy of the items
	_items = [items copy];

	// add the specifiers
	[self insertContiguousSpecifiers:newSpecifiers afterSpecifierID:@"PeopleGroupCell" animated:YES];
}

#pragma mark - Callbacks

- (void)_editTapped:(UIBarButtonItem *)sender {
	// flip the editing state and switch the edit/done item
	[self.table setEditing:!self.table.editing animated:YES];
	[self.navigationItem setRightBarButtonItem:self.table.editing ? _doneBarButtonItem : _editBarButtonItem animated:YES];
}

- (void)addPerson {
	// configure a contact picker view controller
	CNContactPickerViewController *pickerController = [[CNContactPickerViewController alloc] init];
	pickerController.delegate = self;
	pickerController.modalPresentationStyle = UIModalPresentationFormSheet;

	// it’s pretty useless to select a contact without a number or email address
	pickerController.predicateForEnablingContact = [NSPredicate predicateWithFormat:@"phoneNumbers.@count > 0 OR emailAddresses.@count > 0"];

	// present it
	[self.navigationController presentViewController:pickerController animated:YES completion:nil];
}

#pragma mark - CNContactPickerDelegate

- (void)contactPicker:(CNContactPickerViewController *)contactPicker didSelectContact:(CNContact *)contact {
	// merge everything we need into a single array
	NSMutableArray *values = [NSMutableArray array];

	for (CNLabeledValue<CNPhoneNumber *> *value in contact.phoneNumbers) {
		[values addObject:value.value.stringValue];
	}

	for (CNLabeledValue<NSString *> *value in contact.emailAddresses) {
		[values addObject:value.value];
	}
}

#pragma mark - Table View

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	// only the section containing the list can be edited
	return indexPath.section == 1;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	// show the delete button on those items
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	// delete the item at that index path
	HBLogDebug(@"commitEditingStyle %@", indexPath);
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
	// use “Remove” instead of “Delete” for the delete button, and cache the
	// localized string
	static NSString *DeleteString = @"";
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		DeleteString = NSLocalizedStringFromTableInBundle(@"REMOVE", @"Messages", [NSBundle bundleForClass:self.class], @"Button that allows a person to be removed.");
	});

	return DeleteString;
}

@end
