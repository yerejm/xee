#import "XeeImage.h"

@interface XeeImage (Thumbnailing)

- (CGImageRef)makeRGBThumbnailOfSize:(NSInteger)size CF_RETURNS_RETAINED;
- (NSData *)makeJPEGThumbnailOfSize:(NSInteger)size maxBytes:(NSInteger)maxbytes;

@end
