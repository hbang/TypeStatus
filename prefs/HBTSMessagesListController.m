#import "HBTSMessagesListController.h"
#import "HBTSContactHelper.h"
#import "HBTSConversationPreferences.h"
#import "HBTSMessagesPersonListController.h"
#import "HBTSPersonTableCell.h"
#import <Contacts/CNPhoneNumber+Private.h>
#import <Preferences/PSSpecifier.h>

@implementation HBTSMessagesListController {
	UIBarButtonItem *_editBarButtonItem;
	UIBarButtonItem *_doneBarButtonItem;

	HBTSConversationPreferences *_preferences;
	NSMutableDictionary <NSString *, NSString *> *_items;
}

#pragma mark - HBListController

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

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];

	[self reloadSpecifiers];
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
	// TODO: bloated view controller, this should be another class
	_items = [NSMutableDictionary dictionary];
	NSMutableArray *newSpecifiers = [NSMutableArray array];

	// loop over all the preference keys
	for (NSString *key in _preferences.dictionaryRepresentation.allKeys) {
		// get the handle from the key name
		NSString *handle = [key substringToIndex:[key rangeOfString:@"-"].location];

		// if we haven’t yet seen this handle, add it
		if (!_items[handle]) {
			_items[handle] = [HBTSContactHelper nameForHandle:handle useShortName:NO];
		}
	}

	// store the sort order based on the names in alphabetical order
	NSArray *sortOrder = [_items keysSortedByValueUsingComparator:^NSComparisonResult (NSString *obj1, NSString *obj2) {
		return [obj1 localizedCompare:obj2];
	}];

	// loop over the handles we got
	for (NSString *handle in sortOrder) {
		// get the keys
		NSString *name = _items[handle];
		NSString *displayedHandle = handle;

		// if a phone number, get the formatted phone number – hopefully just
		// checking for a “+” prefix is good enough?
		if ([handle hasPrefix:@"+"]) {
			displayedHandle = [CNPhoneNumber phoneNumberWithStringValue:handle].formattedStringValue;
		}

		// create a specifier for it
		PSSpecifier *specifier = [PSSpecifier preferenceSpecifierNamed:name target:self set:nil get:nil detail:HBTSMessagesPersonListController.class cell:PSLinkCell edit:Nil];
		specifier.properties[PSCellClassKey] = HBTSPersonTableCell.class;
		specifier.properties[kHBTSHandleKey] = handle;
		specifier.properties[kHBTSDisplayedHandleKey] = displayedHandle;

		// add it to the array
		[newSpecifiers addObject:specifier];
	}

	// add the specifiers
	[self insertContiguousSpecifiers:newSpecifiers afterSpecifierID:@"PeopleGroupCell" animated:NO];
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
	// TODO: *maybe* should be on its own class? or same as the model controller?
	// merge everything we need into a single array
	NSMutableArray *handles = [NSMutableArray array];

	for (CNLabeledValue<CNPhoneNumber *> *value in contact.phoneNumbers) {
		[handles addObject:value.value.digits];
	}

	for (CNLabeledValue<NSString *> *value in contact.emailAddresses) {
		[handles addObject:value.value];
	}

	// now loop over each of those
	for (NSString *handle in handles) {
		// if we don’t already have it, add it
		if (!_items[handle]) {
			[_preferences addHandle:handle];
		}
	}

	// now reload all specifiers
	[self reloadSpecifiers];
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
	// get the corresponding specifier and then the handle
	PSSpecifier *specifier = [self specifierAtIndexPath:indexPath];
	NSString *handle = specifier.properties[kHBTSHandleKey];

	// remove it from the preferenes
	[_preferences removeHandle:handle];

	// remove from the UI and model too
	[self removeSpecifier:specifier animated:YES];
	[_items removeObjectForKey:handle];
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
