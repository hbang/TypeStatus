#import "HBTSStatusBarItem.h"
#import <UIKit/UIStatusBarForegroundView.h>
#import <UIKit/UIStatusBarItemView.h>
#import <UIKit/UIStatusBarLayoutManager.h>

%hook UIStatusBarLayoutManager

- (UIStatusBarItemView *)_createViewForItem:(UIStatusBarItem *)item data:(id)data actions:(UIStatusBarItemViewActions)actions {
	if (item.class == %c(HBTSStatusBarItem)) {
		Class viewClass = ((HBTSStatusBarItem *)item)._typeStatus_viewClass;

		UIStatusBarItemView *view = [[viewClass alloc] initWithItem:item data:data actions:actions style:self.foregroundView.foregroundStyle];
		view.layoutManager = self;

		BOOL persistentAnimationsEnabled = MSHookIvar<BOOL>(self, "_persistentAnimationsEnabled");
		view.persistentAnimationsEnabled = persistentAnimationsEnabled;

		view.contentMode = UIViewContentModeLeft;
		view.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;

		/*
		// TODO: how do i do this
		UIStatusBarItemView *itemViews[30] = MSHookIvar<UIStatusBarItemView *[30]>(self, "_itemViews");
		itemViews[item.type] = view;
		*/

		return view;
	}

	return %orig;
}

%end
