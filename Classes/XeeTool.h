#import <Cocoa/Cocoa.h>

@class XeeView;

@interface XeeTool:NSObject
{
	XeeView *view;
	BOOL clicking;
}

+(instancetype)toolForView:(XeeView *)ownerview;

-(instancetype)initWithView:(XeeView *)view;

-(void)begin;
-(void)end;

-(void)mouseDownAt:(NSPoint)position;
-(void)mouseUpAt:(NSPoint)position;
-(void)mouseDoubleClickedAt:(NSPoint)position;
-(void)mouseMovedTo:(NSPoint)position relative:(NSPoint)relative;
-(void)mouseDraggedTo:(NSPoint)position relative:(NSPoint)relative;

-(NSCursor *)cursor;
-(void)draw;

@end
