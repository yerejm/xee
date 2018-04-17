#import "XeeBitmapImage.h"

#import "libpng/png.h"

@class XeePNGFrame;

@interface XeePNGImage : XeeBitmapImage {
	NSMutableArray<XeePNGFrame*> *frames;
	png_structp png;
	png_infop info;

	int bit_depth, color_type, interlace_passes;
	int current_line, current_pass;
	int frame_count;
}

+ (NSArray *)fileTypes;
+ (BOOL)canOpenFile:(NSString *)name
		 firstBlock:(NSData *)block
		 attributes:(NSDictionary *)attributes;

- (SEL)initLoader;
- (void)deallocLoader;
- (SEL)startLoading;
- (SEL)loadImage;
- (SEL)finishLoading;

@end

@interface XeePNGFrame : NSObject {
	png_uint_32 num_plays;
	png_uint_32 width;
	png_uint_32 height;
	png_uint_32 xOffset;
	png_uint_32 yOffset;
	png_uint_16 frameDelayNumerator;
	png_uint_16 frameDelayDenominotor;
	png_byte frameDisposeOperation;
	png_byte frameBlendOperation;

}

@end
