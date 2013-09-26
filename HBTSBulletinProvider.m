#import "HBTSBulletinProvider.h"

@implementation HBTSBulletinProvider

+ (instancetype)sharedInstance {
	static HBTSBulletinProvider *sharedInstance;
	static dispatch_once_t *onceToken;
	dispatch_once(&onceToken, ^{
		sharedInstance = [[self alloc] init];
	});

	return sharedInstance;
}

- (void)showBulletinOfType:(HBTSOverlayType)type string:(NSString *)string {
	BBDataProviderWithdrawBulletinsWithRecordID(self, @"ws.hbang.typestatus.bulletin");

	if (!string) {
		return;
	}

	static BBBulletinRequest *bulletinRequest;
	static dispatch_once_t *onceToken;
	dispatch_once(&onceToken, ^{
		bulletinRequest = [[BBBulletinRequest alloc] init];
		bulletinRequest.bulletinID = @"ws.hbang.typestatus.bulletin";
		bulletinRequest.sectionID = @"ws.hbang.typestatus.bulletin";
		bulletinRequest.publisherBulletinID = @"ws.hbang.typestatus.bulletin";
		bulletinRequest.recordID = @"ws.hbang.typestatus.bulletin";
		bulletinRequest.showsUnreadIndicator = NO;
	});
	
	bulletinRequest.title = @"TypeStatus";
	
	switch (type) {
		case HBTSOverlayTypeTyping:
			bulletinRequest.title = L18N(@"Typing");
			break;

		case HBTSOverlayTypeRead:
			bulletinRequest.title = L18N(@"Read");
			break;
	}

	bulletinRequest.message = string;
	bulletinRequest.date = [NSDate date];
	bulletinRequest.lastInterruptDate = [NSDate date];
	BBDataProviderAddBulletin(self, bulletinRequest);
}

#pragma mark - BBDataProvider

- (NSArray *)bulletinsFilteredBy:(unsigned)filter count:(unsigned)count lastCleared:(NSDate *)lastCleared {
	return nil;
}

- (BBSectionInfo *)defaultSectionInfo {
	BBSectionInfo *sectionInfo = [BBSectionInfo defaultSectionInfoForType:0];
	sectionInfo.notificationCenterLimit = 1;
	sectionInfo.sectionID = self.sectionIdentifier;
	return sectionInfo;
}

- (NSString *)sectionIdentifier {
	return @"ws.hbang.typestatus.bulletin";
}

- (NSString *)sectionDisplayName {
	return @"TypeStatus";
}

- (NSArray *)sortDescriptors {
	return [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]];
}

@end
