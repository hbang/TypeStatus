#import "../Global.h"
#import "HBTSListController.h"
#import <Twitter/Twitter.h>
#include <notify.h>

#define URL_ENCODE(string) [(NSString *)CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)(string), NULL, CFSTR(":/=,!$& '()*+;[]@#?"), kCFStringEncodingUTF8) autorelease]

@implementation HBTSListController

#pragma mark - UIViewController

- (void)loadView {
	[super loadView];
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(shareTapped:)];
}

#pragma mark - PSListController

- (NSArray *)specifiers {
	if (!_specifiers) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"TypeStatus" target:self] retain];
	}

	return _specifiers;
}

#pragma mark - Callbacks

- (void)testTypingStatus {
	notify_post("ws.hbang.typestatus/TestTyping");
}

- (void)testReadStatus {
	notify_post("ws.hbang.typestatus/TestRead");
}

- (void)shareTapped:(UIBarButtonItem *)sender {
	if (!prefsBundle) {
		prefsBundle = [[NSBundle bundleForClass:self.class] retain];
	}

	NSString *text = I18N(@"Check out #TypeStatus by HASHBANG Productions!");
	NSURL *url = [NSURL URLWithString:@"http://hbang.ws/typestatus"];

	if (%c(UIActivityViewController)) {
		UIActivityViewController *viewController = [[[UIActivityViewController alloc] initWithActivityItems:@[ text, url ] applicationActivities:nil] autorelease];
		[self.navigationController presentViewController:viewController animated:YES completion:NULL];
	} else if (%c(TWTweetComposeViewController) && [TWTweetComposeViewController canSendTweet]) {
		TWTweetComposeViewController *viewController = [[[TWTweetComposeViewController alloc] init] autorelease];
		viewController.initialText = text;
		[viewController addURL:url];
		[self.navigationController presentViewController:viewController animated:YES completion:NULL];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://twitter.com/intent/tweet?text=%@%%20%@", URL_ENCODE(text), URL_ENCODE(url.absoluteString)]]];
	}
}

@end
