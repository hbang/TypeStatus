#import "HBTSBulletinProvider.h"
#import <BulletinBoard/BBAction.h>
#import <BulletinBoard/BBBulletinRequest.h>
#import <BulletinBoard/BBSectionInfo.h>
#import <BulletinBoard/BBServer.h>
#import <UIKit/UIImage+Private.h>

@implementation HBTSBulletinProvider

+ (instancetype)sharedInstance {
	static HBTSBulletinProvider *sharedInstance = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (void)showBulletinOfType:(HBTSStatusBarType)type string:(NSString *)string {
	BBDataProviderWithdrawBulletinsWithRecordID(self, @"com.apple.MobileSMS");

	if (!string) {
		return;
	}

	static BBBulletinRequest *bulletinRequest = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		bulletinRequest = [[BBBulletinRequest alloc] init];
		bulletinRequest.bulletinID = @"ws.hbang.typestatus.banner";
		bulletinRequest.sectionID = @"ws.hbang.typestatus";
		bulletinRequest.publisherBulletinID = @"ws.hbang.typestatus.banner";
		bulletinRequest.recordID = @"ws.hbang.typestatus.banner";
		bulletinRequest.showsUnreadIndicator = NO;
	});

	bulletinRequest.title = @"TypeStatus";

	switch (type) {
		case HBTSStatusBarTypeTyping:
			bulletinRequest.title = I18N(@"Typing");
			break;

		case HBTSStatusBarTypeRead:
			bulletinRequest.title = I18N(@"Read");
			break;
	}

	bulletinRequest.message = string;
	bulletinRequest.date = [NSDate date];
	bulletinRequest.lastInterruptDate = [NSDate date];
	bulletinRequest.defaultAction = [BBAction actionWithLaunchBundleID:@"com.apple.MobileSMS" callblock:nil];

	BBDataProviderAddBulletin(self, bulletinRequest);
}

#pragma mark - BBDataProvider

- (NSArray *)bulletinsFilteredBy:(NSUInteger)filter count:(NSUInteger)count lastCleared:(NSDate *)lastCleared {
	return nil;
}

- (BBSectionInfo *)defaultSectionInfo {
	BBSectionInfo *sectionInfo = [BBSectionInfo defaultSectionInfoForType:0];
	sectionInfo.notificationCenterLimit = 1;
	sectionInfo.sectionID = self.sectionIdentifier;
	return sectionInfo;
}

- (NSString *)sectionIdentifier {
	return @"ws.hbang.typestatus";
}

- (NSString *)sectionDisplayName {
	return @"TypeStatus";
}

- (NSArray *)sortDescriptors {
	return @[ [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO] ];
}

@end
