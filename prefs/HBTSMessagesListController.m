#import "HBTSMessagesListController.h"

@implementation HBTSMessagesListController

+ (NSString *)hb_specifierPlist {
	return @"Messages";
}

#pragma mark - UIViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	[self _insertPeople];
}

- (void)reloadSpecifiers {
	[super reloadSpecifiers];
	[self _insertPeople];
}

- (void)_insertPeople {
	[self insertSpecifiers:specifiers ]
}

ConversationPrefsList

#pragma mark - Callbacks

- (void)addPerson {
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
