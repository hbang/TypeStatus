#import "HBTSPersonTableCell.h"
#import <Preferences/PSSpecifier.h>

@implementation HBTSPersonTableCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier specifier:specifier];

	if (self) {
		self.detailTextLabel.text = specifier.properties[kHBTSDisplayedHandleKey];
	}

	return self;
}

@end
