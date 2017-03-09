#import "XeeImage.h"

@interface XeeImage (Thumbnailing)

-(CGImageRef)makeRGBThumbnailOfSize:(int)size CF_RETURNS_RETAINED;
-(NSData *)makeJPEGThumbnailOfSize:(int)size maxBytes:(int)maxbytes;

@end
