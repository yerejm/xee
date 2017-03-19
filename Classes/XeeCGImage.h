#include "XeeBitmapImage.h"

@interface XeeCGImage:XeeBitmapImage

-(instancetype)init;
-(instancetype)initWithCGImage:(CGImageRef)cgimage;

-(BOOL)setCGImage:(CGImageRef)cgimageref;
-(void)invertImage;

-(CGColorSpaceRef)createColorSpaceForCGImage CF_RETURNS_RETAINED;

@end
