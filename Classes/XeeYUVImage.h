#import "XeeTileImage.h"

@interface XeeYUVImage:XeeTileImage
{
}

-(instancetype)initWithWidth:(int)pixelwidth height:(int)pixelheight;

-(void)setData:(uint8_t *)pixeldata freeData:(BOOL)willfree width:(int)pixelwidth height:(int)pixelheight bytesPerRow:(int)bprow;
-(BOOL)allocWithWidth:(int)pixelwidth height:(int)pixelheight;

-(void)fixYUVGamma;

-(int)bitsPerComponentForCGImage;
-(int)bytesPerPixelForCGImage;
-(CGColorSpaceRef)createColorSpaceForCGImage CF_RETURNS_RETAINED;
-(int)bitmapInfoForCGImage;
-(XeeReadPixelFunction)readPixelFunctionForCGImage;

@end
