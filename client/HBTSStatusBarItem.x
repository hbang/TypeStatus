#import "HBTSStatusBarItem.h"

%subclass HBTSStatusBarItem : UIStatusBarItem

%property (nonatomic, retain) Class _typeStatus_viewClass;

- (UIStatusBarItemType)type {
	return (UIStatusBarItemType)0;
}

- (Class)viewClass {
	return self._typeStatus_viewClass;
}

- (NSInteger)leftOrder {
	return 0;
}

- (NSInteger)rightOrder {
	return 0;
}

- (NSInteger)centerOrder {
	return 1;
}

- (NSInteger)priority {
	return 1;
}

- (NSString *)indicatorName {
	return @"TypeStatus";
}

%end
