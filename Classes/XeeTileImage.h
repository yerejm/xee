#import "XeeImage.h"
#import "XeeBitmapTile.h"
#import "XeeSampleSet.h"

#include <OpenGL/gl.h>
#include <OpenGL/glu.h>

typedef void (*XeeReadPixelFunction)(uint8_t *row, NSInteger x,
									 NSInteger pixelsize, uint8_t *dest);

@interface XeeTileImage : XeeImage {
  @public
	uint8_t *data;
	NSInteger bytesperpixel, bytesperrow;
  @protected
	BOOL freedata, premultiplied;
	GLuint texintformat, texformat, textype;

	XeeSpan completed, uploaded, drawn;

	GLuint textarget;
	NSMutableArray *tiles;
	BOOL needsupdate;
	NSOpenGLContext *context;
}

- (instancetype)init;

- (void)setData:(uint8_t *)pixeldata
	   freeData:(BOOL)willfree
		  width:(NSInteger)pixelwidth
		 height:(NSInteger)pixelheight
  bytesPerPixel:(NSInteger)bppixel
	bytesPerRow:(NSInteger)bprow
  premultiplied:(BOOL)premult
glInternalFormat:(int)intformat
	   glFormat:(int)format
		 glType:(int)type;

- (void)setCompleted;
- (void)setCompletedRowCount:(NSInteger)count;
- (void)setFirstCompletedRow:(NSInteger)first count:(NSInteger)count;
- (void)invalidate;

- (NSRect)updatedAreaInRect:(NSRect)rect;

- (void)drawInRect:(NSRect)rect
			bounds:(NSRect)bounds
		lowQuality:(BOOL)lowquality;

- (void)allocTexturesRect;
- (void)allocTextures2D;
- (void)uploadTextures;

- (void)drawNormalWithBounds:(NSRect)transbounds;
- (void)drawSampleSet:(XeeSampleSet *)set
			   xScale:(float)x_scale
			   yScale:(float)y_scale
			   bounds:(NSRect)transbounds;
- (void)drawSingleSample:(XeeSamplePoint)sample
				  xScale:(float)xscale
				  yScale:(float)yscale
				  bounds:(NSRect)transbounds;
- (void)drawSamplesOnTextureUnits:(XeeSamplePoint *)samples
							  num:(int)num
						   xScale:(float)xscale
						   yScale:(float)yscale
						   bounds:(NSRect)transbounds;

@property (readonly) GLuint magFilter;

@property (readonly) NSInteger bytesPerRow;
@property (readonly) uint8_t *data NS_RETURNS_INNER_POINTER;

- (CGImageRef)createCGImage CF_RETURNS_RETAINED;
@property (readonly) NSInteger bitsPerComponentForCGImage;
@property (readonly) NSInteger bytesPerPixelForCGImage;
- (CGColorSpaceRef)createColorSpaceForCGImage CF_RETURNS_RETAINED;
@property (readonly) CGBitmapInfo bitmapInfoForCGImage;
- (XeeReadPixelFunction)readPixelFunctionForCGImage;

@end

static inline uint8_t *XeeImageDataRow(XeeTileImage *image, int row)
{
	return image->data + row * image->bytesperrow;
}
