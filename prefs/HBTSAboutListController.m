#import "HBTSAboutListController.h"
#import <UIKit/UITableViewCell+Private.h>

@implementation HBTSAboutListController

#pragma mark - PSListController

- (instancetype)init {
	self = [super init];

	if (self) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"About" target:self] retain];
	}

	return self;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (indexPath.section == 0 && indexPath.row == 0 && [cell respondsToSelector:@selector(_setDrawsSeparatorAtTopOfSection:)]) {
		cell._drawsSeparatorAtTopOfSection = NO;
		cell._drawsSeparatorAtBottomOfSection = NO;
	}
}

@end
