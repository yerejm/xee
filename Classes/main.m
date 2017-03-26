#import <Cocoa/Cocoa.h>
#import "XeePrefKeys.h"

extern BOOL finderlaunch;

int main(int argc, char *argv[])
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	[[NSUserDefaults standardUserDefaults]
		registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:
										   @1, XeeWindowOpeningKey,
										   @1, XeeWindowResizingKey,
										   @YES, XeeJpegYUVKey,
										   @1, XeeShrinkToFitKey,
										   @0, XeeEnlargeToFitKey,
										   @0, XeeUseMipMappingKey,
										   @NO, XeeILBMUseTransparentColorKey,
										   @NO, XeeILBMUseMaskKey,
										   @YES, XeePNGStrip16BitKey,
										   @NO, XeeForce2DKey,
										   @2, XeeAntialiasQualityKey,
										   @NO, XeeUseOrientationKey,
										   @NO, XeeRememberZoomKey,
										   @NO, XeeRememberFocusKey,
										   @1, XeeSavedZoomKey,
										   @1, XeeScrollWheelFunctionKey,
										   @NO, XeeWrapImageBrowsingKey,
										   @NO, XeeAutoFullscreenKey,
										   @NO, XeeRandomizeSlideshowKey,
										   @5, XeeSlideshowDelayKey,
										   @0, XeeSlideshowCustomDelayKey,
										   @0, XeeDefaultSortingOrderKey,
										   @YES, XeeOpenFilePanelOnLaunchKey,
										   @NO, XeeUpsampleImageKey,
										   @NO, XeeQuitOnCloseKey,
										   [NSArchiver archivedDataWithRootObject:[NSColor whiteColor]], XeeDefaultImageBackgroundKey,
										   [NSArchiver archivedDataWithRootObject:[NSColor grayColor]], XeeWindowBackgroundKey,
										   [NSArchiver archivedDataWithRootObject:[NSColor grayColor]], XeeFullScreenBackgroundKey,
										   nil]];

	// Include the system sound prefs on Leopard
	if (floor(NSAppKitVersionNumber) > 824)
		[[NSUserDefaults standardUserDefaults] addSuiteNamed:@"com.apple.systemsound"];

	[pool release];

	finderlaunch = argc != 1;

	return NSApplicationMain(argc, (const char **)argv);
}
