#import "HBTSSwitchTableViewCell.h"

@implementation HBTSSwitchTableViewCell

+ (NSString *)identifier {
	return @"TypeStatusSwitchCell";
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

	if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;

		_control = [[UISwitch alloc] init];

		self.accessoryView = _control;
	}

	return self;
}

- (void)dealloc {
	[_control release];
	[super dealloc];
}

@end
