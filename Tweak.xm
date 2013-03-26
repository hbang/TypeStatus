#import <libstatusbar/LSStatusBarItem.h>
#import <IMFoundation/FZMessage.h>

int typingIndicators = 0;
LSStatusBarItem *statusBarItem;

%hook IMChatRegistry
-(void)account:(id)account chat:(id)chat style:(unsigned char)style chatProperties:(id)properties messageReceived:(FZMessage *)message {
	%orig;

	if (message.flags == 4096) {
		typingIndicators++;

		if (!statusBarItem) {
			statusBarItem = [[%c(LSStatusBarItem) alloc] initWithIdentifier:@"ws.hbang.typestatus.icon" alignment:StatusBarAlignmentRight];
			statusBarItem.imageName = @"TypeStatus";
		}

		statusBarItem.visible = YES;
	} else {
		typingIndicators--;

		if (typingIndicators < 0) {
			typingIndicators = 0;
		}

		if (typingIndicators == 0 && statusBarItem) {
			statusBarItem.visible = NO;
		}
	}
}
%end
