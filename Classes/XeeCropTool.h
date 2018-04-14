#import "XeeTool.h"

typedef NS_ENUM(int, XeeCropArea) {
	XeeAreaOutside = 0,
	XeeAreaInside = 1,
	XeeAreaTopLeft = 2,
	XeeAreaTopRight = 3,
	XeeAreaBottomLeft = 4,
	XeeAreaBottomRight = 5,
	XeeAreaTop = 6,
	XeeAreaBottom = 7,
	XeeAreaLeft = 8,
	XeeAreaRight = 9,
};

typedef NS_ENUM(int, XeeCropMode) {
	XeeCropModeNone = 0,
	XeeCropModeResize = 1,
	XeeCropModeVerticalResize = 2,
	XeeCropModeHorizontalResize = 3,
	XeeCropModeMove = 4,
};

@interface XeeCropTool : XeeTool {
	CGFloat o, i;

	NSInteger crop_x, crop_y, crop_width, crop_height;
	XeeCropArea area;
	XeeCropMode mode;
	NSInteger start_x, start_y;
	CGFloat offs_x, offs_y;
}

- (id)initWithView:(XeeView *)ownerview;

- (void)mouseDownAt:(NSPoint)position;
- (void)mouseUpAt:(NSPoint)position;
- (void)mouseDoubleClickedAt:(NSPoint)position;
- (void)mouseMovedTo:(NSPoint)position relative:(NSPoint)relative;
- (void)mouseDraggedTo:(NSPoint)position relative:(NSPoint)relative;
- (void)findAreaForPosition:(NSPoint)position;

- (NSCursor *)cursor;
- (void)draw;

@property (readonly) NSRect croppingRect;

@end
