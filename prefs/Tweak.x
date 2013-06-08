#import <Preferences/PSSliderTableCell.h>

%hook PSSliderTableCell
- (BOOL)canReload { %log; BOOL r = %orig; NSLog(@" = %d", r); return r; }
- (void)refreshCellContentsWithSpecifier:(id)arg1 { %log; %orig; }
- (id)initWithStyle:(int)arg1 reuseIdentifier:(id)arg2 specifier:(id)arg3 { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (id)controlValue { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (id)newControl { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (id)valueLabel { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)controlChanged:(id)arg1 { %log; %orig; }
- (void)dealloc { %log; %orig; }
- (id)control { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)setControl:(id)arg1 { %log; %orig; }
- (void)setValue:(id)arg1 { %log; %orig; }
- (void)prepareForReuse { %log; %orig; }
- (id)titleLabel { %log; id r = %orig; NSLog(@" = %@", r); return r; }
- (void)layoutSubviews { %log; %orig; }
- (void)setCellEnabled:(BOOL)arg1 { %log; %orig; }
%end
