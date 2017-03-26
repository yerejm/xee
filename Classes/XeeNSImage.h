#include "XeeBitmapImage.h"

@interface XeeNSImage : XeeBitmapImage {
	NSBitmapImageRep *rep;
}

- (instancetype)init;
- (instancetype)initWithNSBitmapImageRep:(NSBitmapImageRep *)imagerep;
//-(id)initWithConvertedNSImageRep:(NSImageRep *)imagerep type:(int)pixeltype;

- (BOOL)setNSBitmapImageRep:(NSBitmapImageRep *)imagerep;
//-(BOOL)setConvertedNSImageRep:(NSImageRep *)imagerep type:(int)pixeltype;

@end
