#import "HBTSDaemonServiceDelegate.h"

int main(int argc, char *argv[]) {
	HBTSDaemonServiceDelegate *delegate = [[HBTSDaemonServiceDelegate alloc] init];

	NSXPCListener *listener = [NSXPCListener serviceListener];
	listener.delegate = delegate;
	[listener resume];

	return EXIT_FAILURE;
}
