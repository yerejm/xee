#import "XeeBitmapImage.h"

@class XeePalette;

@interface XeeIndexedRawImage:XeeBitmapImage
{
	XeePalette *pal;
	uint8_t *buffer;
	NSInteger bitdepth,inbpr;
}

-(instancetype)initWithHandle:(CSHandle *)fh width:(NSInteger)framewidth height:(NSInteger)frameheight
palette:(XeePalette *)palette;
-(instancetype)initWithHandle:(CSHandle *)fh width:(NSInteger)framewidth height:(NSInteger)frameheight
palette:(XeePalette *)palette bytesPerRow:(NSInteger)bytesperinputrow;
-(instancetype)initWithHandle:(CSHandle *)fh width:(NSInteger)framewidth height:(NSInteger)frameheight
depth:(int)framedepth palette:(XeePalette *)palette;
-(instancetype)initWithHandle:(CSHandle *)fh width:(NSInteger)framewidth height:(NSInteger)frameheight
depth:(int)framedepth palette:(XeePalette *)palette bytesPerRow:(NSInteger)bytesperinputrow;

-(void)load;

@end

@interface XeePalette:NSObject
{
	uint32_t pal[256];
	NSInteger numcolours;
	BOOL istrans;
}

+(instancetype)palette;

@property (readonly) NSInteger numberOfColours;
-(uint32_t)colourAtIndex:(NSInteger)index;
@property (readonly, getter=isTransparent) BOOL isTransparent;
@property (readonly) uint32_t *colours NS_RETURNS_INNER_POINTER;

-(void)setColourAtIndex:(int)index red:(uint8_t)red green:(uint8_t)green blue:(uint8_t)blue;
-(void)setColourAtIndex:(int)index red:(uint8_t)red green:(uint8_t)green blue:(uint8_t)blue alpha:(uint8_t)alpha;
-(void)setTransparent:(int)index;

-(void)convertIndexes:(uint8_t *)indexes count:(NSInteger)count depth:(NSInteger)depth toRGB8:(uint8_t *)dest;
-(void)convertIndexes:(uint8_t *)indexes count:(NSInteger)count depth:(NSInteger)depth toARGB8:(uint8_t *)dest;

@end
