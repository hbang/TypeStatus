#import "HBTSMessagesListController.h"
#import "../global/HBTSConversationPreferences.h"
#import <Preferences/PSSpecifier.h>

@implementation HBTSMessagesListController {
	UIBarButtonItem *_editBarButtonItem;
	UIBarButtonItem *_doneBarButtonItem;
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

- (void)_editTapped:(UIBarButtonItem *)sender {
	[self.table setEditing:!self.table.editing animated:YES];
	self.navigationItem.rightBarButtonItem = self.table.editing ? _doneBarButtonItem : _editBarButtonItem;
}

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

#pragma mark - Table View

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath.section == 1;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	HBLogDebug(@"commitEditingStyle %@", indexPath);
}

#pragma mark - Memory management

- (void)dealloc {
	[_editBarButtonItem release];
	[_doneBarButtonItem release];

	[super dealloc];
}

@end
