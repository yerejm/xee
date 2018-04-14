#import "XeeBitmapRawImage.h"

@implementation XeeBitmapRawImage

- (id)initWithHandle:(CSHandle *)fh width:(NSInteger)w height:(NSInteger)h
{
	return [self initWithHandle:fh width:w height:h bytesPerRow:(w + 7) / 8];
}

- (id)initWithHandle:(CSHandle *)fh width:(NSInteger)w height:(NSInteger)h bytesPerRow:(NSInteger)bpr
{
	if (self = [super initWithHandle:fh]) {
		width = w;
		height = h;
		bytesperfilerow = bpr;
		zero = 255;
		one = 0;
		buffer = NULL;
	}
	return self;
}

- (void)dealloc
{
	free(buffer);
}

- (void)setZeroPoint:(float)low onePoint:(float)high
{
	zero = low * 255;
	one = high * 255;
}

- (void)load
{
	if (!handle) {
		XeeImageLoaderDone(NO);
	}
	XeeImageLoaderHeaderDone();

	if (![self allocWithType:XeeBitmapTypeLuma8 width:width height:height])
		XeeImageLoaderDone(NO);

	buffer = malloc(bytesperfilerow);
	if (!buffer)
		XeeImageLoaderDone(NO);

	for (int row = 0; row < height; row++) {
		[handle readBytes:bytesperfilerow toBuffer:buffer];

		uint8_t *rowptr = XeeImageDataRow(self, row);
		for (int x = 0; x < width; x++) {
			if (buffer[x >> 3] & (0x80 >> (x & 7)))
				*rowptr++ = one;
			else
				*rowptr++ = zero;
		}

		[self setCompletedRowCount:row + 1];
		XeeImageLoaderYield();
	}

	free(buffer);
	buffer = NULL;

	XeeImageLoaderDone(YES);
}

@end
