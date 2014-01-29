#import "HBTSAboutListController.h"
#import <UIKit/UITableViewCell+Private.h>

@implementation HBTSAboutListController

#pragma mark - PSListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"About" target:self] retain];
	}

	return _specifiers;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 0) {
		cell._drawsSeparatorAtTopOfSection = NO;
		cell._drawsSeparatorAtBottomOfSection = NO;
	}
}

@end
