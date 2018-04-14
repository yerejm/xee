#import "XeeTileImage.h"

@interface XeeYUVImage : XeeTileImage

- (instancetype)initWithWidth:(NSInteger)pixelwidth height:(NSInteger)pixelheight;

- (void)setData:(uint8_t *)pixeldata
	   freeData:(BOOL)willfree
		  width:(NSInteger)pixelwidth
		 height:(NSInteger)pixelheight
	bytesPerRow:(NSInteger)bprow;
- (BOOL)allocWithWidth:(NSInteger)pixelwidth height:(NSInteger)pixelheight;

- (void)fixYUVGamma;

@property (readonly) NSInteger bitsPerComponentForCGImage;
@property (readonly) NSInteger bytesPerPixelForCGImage;
- (CGColorSpaceRef)createColorSpaceForCGImage CF_RETURNS_RETAINED;
@property (readonly) CGBitmapInfo bitmapInfoForCGImage;
- (XeeReadPixelFunction)readPixelFunctionForCGImage;

@end
