#import "XeeTypes.h"
#import "XeeImage.h"

#include <OpenGL/gl.h>
#include <OpenGL/glu.h>

@class XeeImage,XeeController,XeeTool;
@protocol XeeViewDelegate;
@protocol XeeImageDelegate;

@interface XeeView:NSOpenGLView <XeeImageDelegate>
{
	XeeImage *image;
	XeeTool *tool;

	int x,y;
	int width,height;
	int imgwidth,imgheight;
	BOOL invalidated;

	BOOL drawresize,hidecursor,lowquality,inside,clicking;

	NSTimer *scrolltimer;
	BOOL up,down,left,right;
	double prevtime;

	GLuint resizetex;

	__unsafe_unretained id<XeeViewDelegate> delegate;
}

-(instancetype)initWithFrame:(NSRect)frameRect;

-(BOOL)acceptsFirstResponder;
-(BOOL)isOpaque;
-(BOOL)isFlipped;

-(void)reshape;

-(void)drawRect:(NSRect)rect;
-(void)drawResizeHandle;

-(void)keyDown:(NSEvent *)event;
-(void)keyUp:(NSEvent *)event;
-(void)mouseDown:(NSEvent *)event;
-(void)mouseUp:(NSEvent *)event;
-(void)mouseDragged:(NSEvent *)event;
-(void)scrollWheel:(NSEvent *)event;

-(void)xeeImageLoadingProgress:(XeeImage *)msgimage;
-(void)xeeImageDidChange:(XeeImage *)msgimage;
-(void)xeeImageSizeDidChange:(XeeImage *)msgimage;
-(void)xeeImagePropertiesDidChange:(XeeImage *)msgimage;

-(void)invalidate;
-(void)invalidateTool;
-(void)invalidateImageAndTool;
-(void)updateCursorForMousePosition:(NSPoint)pos;

-(void)startScrolling;
-(void)stopScrolling;
-(void)scroll:(NSTimer *)timer;

@property NSPoint focus;
-(void)clampCoords;

@property (readonly) NSRect imageRect;
@property (readonly) XeeMatrix imageToViewTransformMatrix;
@property (readonly) XeeMatrix viewToImageTransformMatrix;
@property (assign) id<XeeViewDelegate> delegate;
@property (nonatomic, retain) XeeImage *image;
@property (nonatomic, retain) XeeTool *tool;

-(void)setImageSize:(NSSize)size;
-(void)setDrawResizeCorner:(BOOL)draw;
-(void)setCursorShouldHide:(BOOL)shouldhide;

-(void)hideCursor;
-(void *)readPixels:(int)bytesperrow;
-(void)copyGLtoQuartz;

@end

@protocol XeeViewDelegate <NSObject>
@optional
-(void)xeeView:(XeeView *)view imageDidChange:(XeeImage *)image;
-(void)xeeView:(XeeView *)view imageSizeDidChange:(XeeImage *)image;
-(void)xeeView:(XeeView *)view imagePropertiesDidChange:(XeeImage *)image;

@end
