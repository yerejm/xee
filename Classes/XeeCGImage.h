#include "XeeBitmapImage.h"

typedef void *CGAccessSessionRef;

@interface XeeCGImage:XeeBitmapImage
{
	CGImageRef imageref;
	CGAccessSessionRef session;
}

-(instancetype)init;
-(instancetype)initWithCGImage:(CGImageRef)cgimage;

-(BOOL)setCGImage:(CGImageRef)cgimageref;
-(void)invertImage;

-(CGColorSpaceRef)createColorSpaceForCGImage CF_RETURNS_RETAINED;

@end
