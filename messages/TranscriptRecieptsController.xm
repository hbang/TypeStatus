#import "HBTSConversationPreferences.h"
#import "HBTSSwitchTableViewCell.h"
#import <ChatKit/CKConversation.h>
#import <ChatKit/CKTranscriptRecipientsController.h>
#import <ChatKit/CKTranscriptRecipientsHeaderFooterView.h>
#import <UIKit/UITableView+Private.h>

#pragma mark - Constants

static NSInteger const kHBTSNumberOfExtraRows = 2;

#pragma mark - Variables

NSBundle *bundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatus.bundle"];

#pragma mark - View controller hook

@interface CKTranscriptRecipientsController ()

- (HBTSSwitchTableViewCell *)_typeStatus_switchCellForIndexPath:(NSIndexPath *)indexPath;
- (void)_typeStatus_configureDisableTypingCell:(HBTSSwitchTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)_typeStatus_configureDisableReadReceiptsCell:(HBTSSwitchTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic) NSInteger _typeStatus_sectionIndex;
@property (nonatomic) NSInteger _typeStatus_originalRowCount;
@property (nonatomic, retain) HBTSConversationPreferences *_typeStatus_preferences;

@end

%hook CKTranscriptRecipientsController

%property (nonatomic, retain) NSInteger _typeStatus_sectionIndex;
%property (nonatomic, retain) NSInteger _typeStatus_originalRowCount;
%property (nonatomic, retain) HBTSConversationPreferences *_typeStatus_preferences;

#pragma mark - UIViewController

- (void)loadView {
	%orig;

	self._typeStatus_preferences = [[HBTSConversationPreferences alloc] init];

	[self.tableView registerClass:HBTSSwitchTableViewCell.class forCellReuseIdentifier:[HBTSSwitchTableViewCell identifier]];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (![HBTSConversationPreferences shouldEnable]) {
		return %orig;
	}

	NSInteger sections = %orig;

	if (self.conversation._chatSupportsTypingIndicators && !self.conversation.isGroupConversation) {
		self._typeStatus_sectionIndex = sections - 2;
	}

	return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (![HBTSConversationPreferences shouldEnable]) {
		return %orig;
	}

	NSInteger sectionIndex = self._typeStatus_sectionIndex;

	if (sectionIndex == 0 || section != sectionIndex) {
		return %orig;
	}

	NSInteger rows = %orig;
	self._typeStatus_originalRowCount = rows;

	return rows + kHBTSNumberOfExtraRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	if (![HBTSConversationPreferences shouldEnable]) {
		return %orig;
	}

	NSInteger sectionIndex = self._typeStatus_sectionIndex;
	NSInteger originalRowCount = self._typeStatus_originalRowCount;

	if (sectionIndex == 0 || indexPath.section != sectionIndex || indexPath.row < originalRowCount) {
		return %orig;
	}

	HBTSSwitchTableViewCell *cell = [self _typeStatus_switchCellForIndexPath:indexPath];

	if (indexPath.row == originalRowCount) {
		[self _typeStatus_configureDisableTypingCell:cell atIndexPath:indexPath];
	} else if (indexPath.section == originalRowCount + 1) {
		[self _typeStatus_configureDisableReadReceiptsCell:cell atIndexPath:indexPath];
	}

	return cell;
}

#pragma mark - Callbacks

%new - (HBTSSwitchTableViewCell *)_typeStatus_switchCellForIndexPath:(NSIndexPath *)indexPath {
	HBTSSwitchTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[HBTSSwitchTableViewCell identifier] forIndexPath:indexPath];

	if (!cell) {
		cell = [[HBTSSwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[HBTSSwitchTableViewCell identifier]];
	}

	[cell.control addTarget:self action:@selector(_typeStatus_switchValueChanged:) forControlEvents:UIControlEventValueChanged];

	return cell;
}

%new - (void)_typeStatus_configureDisableTypingCell:(HBTSSwitchTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	cell.control.tag = 0;
	cell.control.on = [self._typeStatus_preferences typingNotificationsEnabledForConversation:self.conversation];
	cell.textLabel.text = [bundle localizedStringForKey:@"SEND_TYPING_NOTIFICATIONS" value:nil table:@"Messages"];
}

%new - (void)_typeStatus_configureDisableReadReceiptsCell:(HBTSSwitchTableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	cell.control.tag = 1;
	cell.control.on = [self._typeStatus_preferences readReceiptsEnabledForConversation:self.conversation];
	cell.textLabel.text = [bundle localizedStringForKey:@"SEND_READ_RECEIPTS" value:nil table:@"Messages"];
}

%new - (void)_typeStatus_switchValueChanged:(UISwitch *)sender {
	switch (sender.tag) {
		case 0:
			[self._typeStatus_preferences setTypingNotificationsEnabled:sender.on forConversation:self.conversation];
			break;

		case 1:
			[self._typeStatus_preferences setReadReceiptsEnabled:sender.on forConversation:self.conversation];
			break;
	}
}

%end

%ctor {
	// only initialise these hooks if we’re allowed to
	if ([HBTSConversationPreferences isAvailable]) {
		%init;
	}
}
