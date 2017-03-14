#import "XeeMultiImage.h"
#import "XeeBitmapImage.h"

#import <XADMaster/CSByteStreamHandle.h>

#define XeePhotoshopBitmapMode 0
#define XeePhotoshopGreyscaleMode 1
#define XeePhotoshopIndexedMode 2
#define XeePhotoshopRGBMode 3
#define XeePhotoshopCMYKMode 4
#define XeePhotoshopMultichannelMode 7
#define XeePhotoshopDuotoneMode 8
#define XeePhotoshopLabMode 9



@interface XeePhotoshopImage:XeeMultiImage
{
	int bitdepth,mode,channels;

	SEL loadersel;
	int loaderframe;
}

-(CSHandle *)handleForNumberOfChannels:(int)requiredchannels alpha:(BOOL)alpha;

-(instancetype)init;
-(SEL)initLoader;

-(int)bitDepth;
-(int)mode;

@end



@interface XeePackbitsHandle:CSByteStreamHandle
{
	int rows,bytesperrow;
	off_t totalsize,*offsets;

	int spanleft;
	uint8_t spanbyte;
	BOOL literal;
}

-(instancetype)initWithHandle:(CSHandle *)handle rows:(int)numrows bytesPerRow:(int)bpr channel:(int)channel of:(int)numchannels previousSize:(off_t)prevsize;

-(uint8_t)produceByteAtOffset:(off_t)pos;

@property (readonly) off_t totalSize;

@end

@interface XeeDeltaHandle:CSByteStreamHandle
{
	int cols,depth;
	uint16_t curr;
}

-(instancetype)initWithHandle:(CSHandle *)handle depth:(int)bitdepth columns:(int)columns;
-(uint8_t)produceByteAtOffset:(off_t)pos;

@end
