#include "XeeTypes.h"

#import <OpenGL/GL.h>
#import <OpenGL/GLu.h>

@interface XeeBitmapTile : NSObject {
	NSInteger x, y, width, height;

	GLuint tex, textarget, texintformat, textype, texformat;
	int realwidth;
	void *data;

	BOOL created;
	XeeSpan uploaded;

	GLuint lists;
}

- (instancetype)initWithTarget:(GLuint)tt
				internalFormat:(GLuint)tif
							 x:(NSInteger)x
							 y:(NSInteger)y
						 width:(NSInteger)width
						height:(NSInteger)height
						format:(GLuint)tf
						  type:(GLuint)tt
						  data:(void *)d;

- (void)uploadWithCompletedSpan:(XeeSpan)global_completed;
- (void)invalidate;

- (void)drawWithBounds:(NSRect)bounds
			 minFilter:(GLuint)minfilter
			 magFilter:(GLuint)magfilter;
- (void)drawMultipleWithBounds:(NSRect)bounds
					 minFilter:(GLuint)minfilter
					 magFilter:(GLuint)magfilter
						   num:(int)num;

@end
