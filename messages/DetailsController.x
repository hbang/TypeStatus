#import "HBTSConversationPreferences.h"
#import "HBTSSwitchTableViewCell.h"
#import <ChatKit/CKConversation.h>
#import <ChatKit/CKDetailsChatOptionsCell.h>
#import <ChatKit/CKDetailsController.h>
#import <ChatKit/CKDetailsTableView.h>
#import <version.h>

#pragma mark - Variables

NSBundle *bundle;

#pragma mark - View controller hook

@interface CKDetailsController ()

- (CKDetailsChatOptionsCell *)_typeStatus_switchCellForIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic) NSInteger _typeStatus_sectionIndex;
@property (nonatomic) NSInteger _typeStatus_originalRowCount;
@property (nonatomic, retain) HBTSConversationPreferences *_typeStatus_preferences;

@end

%hook CKDetailsController

%property (nonatomic, retain) NSInteger _typeStatus_sectionIndex;
%property (nonatomic, retain) NSInteger _typeStatus_originalRowCount;
%property (nonatomic, retain) HBTSConversationPreferences *_typeStatus_preferences;

#pragma mark - UIViewController

- (void)loadView {
	%orig;

	self._typeStatus_preferences = [[HBTSConversationPreferences alloc] init];

	// instantiate our switch cell class so we can use it by reuse identifier later
	[self.tableView registerClass:HBTSSwitchTableViewCell.class forCellReuseIdentifier:[HBTSSwitchTableViewCell identifier]];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	// if we’re disabled, don’t do anything further
	if (![HBTSConversationPreferences shouldEnable]) {
		return %orig;
	}

	NSInteger sections = %orig;

	// if the chat supports typing indicators and isn’t a group conversation (which doesn’t support
	// them despite _chatSupportsTypingIndicators being YES) then store the section index to stick our
	// cells in
	if (self.conversation._chatSupportsTypingIndicators && !self.conversation.isGroupConversation) {
		self._typeStatus_sectionIndex = sections - 4;
	}

	return sections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	// if we’re disabled, don’t do anything further
	if (![HBTSConversationPreferences shouldEnable]) {
		return %orig;
	}

	NSInteger sectionIndex = self._typeStatus_sectionIndex;

	// if we haven’t got a section index yet, or this isn’t the same section, return
	if (sectionIndex == 0 || section != sectionIndex) {
		return %orig;
	}

	// store the original row count
	NSInteger rows = %orig;
	self._typeStatus_originalRowCount = rows;

	// return a new row count that includes our added cell
	return rows + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	// if we’re disabled, don’t do anything further
	if (![HBTSConversationPreferences shouldEnable]) {
		return %orig;
	}

	NSInteger sectionIndex = self._typeStatus_sectionIndex;
	NSInteger originalRowCount = self._typeStatus_originalRowCount;

	// if we haven’t got a section index yet, or this isn’t the same section, return
	if (sectionIndex == 0 || indexPath.section != sectionIndex) {
		return %orig;
	} else if (indexPath.row == originalRowCount) {
		// if this is the last row, place the send read receipts cell in last position so we can put our
		// cell before it
		indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1 inSection:indexPath.section];

		// grab the cell, configure it, and return it
		CKDetailsChatOptionsCell *cell = (CKDetailsChatOptionsCell *)%orig(tableView, indexPath);
		cell.controlSwitch.on = [self._typeStatus_preferences readReceiptsEnabledForChat:self.conversation.chat];

		return cell;
	} else if (indexPath.row == originalRowCount - 1) {
		// if this is the second-last row, place our typing cell here. grab the cell, configure it, and
		// return it
		CKDetailsChatOptionsCell *cell = [self _typeStatus_switchCellForIndexPath:indexPath];
		cell.controlSwitch.on = [self._typeStatus_preferences typingNotificationsEnabledForChat:self.conversation.chat];

		return cell;
	} else {
		// we have nothing to do for this cell, so return
		return %orig;
	}
}

#pragma mark - Callbacks

%new - (CKDetailsChatOptionsCell *)_typeStatus_switchCellForIndexPath:(NSIndexPath *)indexPath {
	// retrieve a reusable cell
	CKDetailsChatOptionsCell *cell = [self.tableView dequeueReusableCellWithIdentifier:[%c(CKDetailsChatOptionsCell) reuseIdentifier] forIndexPath:indexPath];

	// set the label and value change target
	cell.textLabel.text = [bundle localizedStringForKey:@"SEND_TYPING_NOTIFICATIONS" value:nil table:@"Messages"];
	[cell.controlSwitch addTarget:self action:@selector(_typeStatus_typingSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];

	// configure the separators (psst apple, it’s spelled with an a not an e)
	cell.indentTopSeperator = YES;
	cell.bottomSeperator.hidden = YES;

	return cell;
}

%new - (void)_typeStatus_typingSwitchValueChanged:(UISwitch *)sender {
	// update our typing enabled state
	[self._typeStatus_preferences setTypingNotificationsEnabled:sender.on forChat:self.conversation.chat];
}

- (void)readReceiptsSwitchValueChanged:(UISwitch *)sender {
	// let the system read receipt state update itself
	%orig;

	// update ours as well
	[self._typeStatus_preferences setReadReceiptsEnabled:sender.on forChat:self.conversation.chat];
}

%end

%ctor {
	// only initialise these hooks if we’re allowed to, and only on iOS 10
	if ([HBTSConversationPreferences isAvailable] && IS_IOS_OR_NEWER(iOS_10_0)) {
		bundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/TypeStatus.bundle"];
		
		%init;
	}
}
