#import "HBTSNotification+Private.h"
#import "HBTSStatusBarAlertServer.h"

@interface HBTSNotification ()

// TODO: make these public?
@property (nonatomic) NSTimeInterval timeout;
@property (nonatomic) HBTSNotificationType notificationType;
@property (nonatomic) BOOL direction;

@end

@implementation HBTSNotification

#pragma mark - Init

+ (instancetype)hideNotification {
	static dispatch_once_t onceToken;
	static HBTSNotification *hideNotification = nil;
	dispatch_once(&onceToken, ^{
		hideNotification = [[HBTSNotification alloc] init];
	});

	return hideNotification;
}

- (instancetype)init {
	self = [super init];

	if (self) {
		// set defaults for things that don’t have a nil default
		_boldRange = NSMakeRange(0, 0);
		_date = [NSDate date];
		_timeout = -1;
	}

	return self;
}

- (instancetype)initWithType:(HBTSMessageType)type sender:(NSString *)sender iconName:(NSString *)iconName {
	self = [self init];

	if (self) {
		if (type != HBTSMessageTypeTypingEnded) {
			_direction = YES;
			_content = [HBTSStatusBarAlertServer textForType:type sender:sender boldRange:&_boldRange];
			_statusBarIconName = iconName;
		}
	}

	return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
	self = [self init];

	if (self) {
		// deserialise the easy stuff
		_sourceBundleID = [dictionary[kHBTSMessageSourceKey] copy];
		_content = [dictionary[kHBTSMessageContentKey] copy];
		_statusBarIconName = [dictionary[kHBTSMessageIconNameKey] copy];
		_direction = ((NSNumber *)dictionary[kHBTSMessageDirectionKey]).boolValue;

		if (dictionary[kHBTSMessageSendDateKey]) {
			id date = dictionary[kHBTSMessageSendDateKey];

			// the date will be serialized to an NSNumber if it’s sent in an IPC
			// message
			if ([date isKindOfClass:NSNumber.class]) {
				_date = [NSDate dateWithTimeIntervalSince1970:((NSNumber *)date).doubleValue];
			} else if ([date isKindOfClass:NSDate.class]) {
				_date = [date copy];
			}
		}

		if (![dictionary[kHBTSMessageActionURLKey] isEqualToString:@""]) {
			_actionURL = [NSURL URLWithString:dictionary[kHBTSMessageActionURLKey]];
		}

		if (dictionary[kHBTSMessageTimeoutKey]) {
			_timeout = ((NSNumber *)dictionary[kHBTSMessageTimeoutKey]).doubleValue;
		}

		// deserialize the bold range to an NSRange
		NSArray <NSNumber *> *boldRangeArray = dictionary[kHBTSMessageBoldRangeKey];
		_boldRange = NSMakeRange(boldRangeArray[0].unsignedIntegerValue, boldRangeArray[1].unsignedIntegerValue);
	}

	return self;
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; sourceBundleID = %@; content = %@; statusBarIconName = %@>", self.class, self, _sourceBundleID, _content, _statusBarIconName];
}

#pragma mark - Serialization

- (NSString *)_contentWithBoldRange:(out NSRange *)boldRange {
	if (_direction) {
		// we should never end up with nothing to return. crash if so
		NSAssert(_content, @"No notification content found");
		NSAssert(_content.length > 0, @"No notification content found");

		// grab the bold range, and return the content
		*boldRange = _boldRange;
		return _content;
	} else {
		// if this is a hide notification, return nothing
		*boldRange = NSMakeRange(0, 0);
		return @"";
	}
}

- (NSDictionary *)dictionaryRepresentation {
	// grab the content and bold range
	NSRange boldRange = NSMakeRange(0, 0);
	NSString *content = [self _contentWithBoldRange:&boldRange];

	NSParameterAssert(_sourceBundleID);
	NSParameterAssert(_date);

	// return serialized dictionary
	return @{
		kHBTSMessageSourceKey: _sourceBundleID,
		kHBTSMessageContentKey: content,
		kHBTSMessageBoldRangeKey: @[ @(boldRange.location), @(boldRange.length) ],
		kHBTSMessageIconNameKey: _statusBarIconName ?: @"",
		kHBTSMessageActionURLKey: _actionURL ? _actionURL.absoluteString : @"",
		kHBTSMessageDirectionKey: @(_direction),
		kHBTSMessageSendDateKey: _date,
		kHBTSMessageTimeoutKey: @(_timeout)
	};
}

@end
