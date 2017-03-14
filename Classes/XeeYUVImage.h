#import "XeeTileImage.h"

@interface XeeYUVImage:XeeTileImage

-(instancetype)initWithWidth:(int)pixelwidth height:(int)pixelheight;

-(void)setData:(uint8_t *)pixeldata freeData:(BOOL)willfree width:(NSInteger)pixelwidth height:(NSInteger)pixelheight bytesPerRow:(NSInteger)bprow;
-(BOOL)allocWithWidth:(int)pixelwidth height:(int)pixelheight;

-(void)fixYUVGamma;

@property (readonly) NSInteger bitsPerComponentForCGImage;
@property (readonly) NSInteger bytesPerPixelForCGImage;
-(CGColorSpaceRef)createColorSpaceForCGImage CF_RETURNS_RETAINED;
@property (readonly) CGBitmapInfo bitmapInfoForCGImage;
-(XeeReadPixelFunction)readPixelFunctionForCGImage;

@end
