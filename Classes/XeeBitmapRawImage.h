#import "XeeBitmapImage.h"

@interface XeeBitmapRawImage:XeeBitmapImage
{
	int bytesperfilerow;
	uint8_t zero,one;
	uint8_t *buffer;
}

-(instancetype)initWithHandle:(CSHandle *)fh width:(NSInteger)w height:(NSInteger)h;
-(instancetype)initWithHandle:(CSHandle *)fh width:(NSInteger)w height:(NSInteger)h bytesPerRow:(NSInteger)bpr;

-(void)setZeroPoint:(float)low onePoint:(float)high;

-(void)load;

@end
