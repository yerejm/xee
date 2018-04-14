#import "XeeMultiImage.h"

#if !__LP64__

#if __has_include(<QuickTime/QuickTime.h>)
#include <QuickTime/ImageCompression.h>
#include <QuickTime/QuickTimeComponents.h>
#endif

@class XeeBitmapImage;

@interface XeeQuicktimeImage : XeeMultiImage {
	/*GraphicsImportComponent*/ ComponentInstance gi;
	int current_image, current_height;
}

+ (BOOL)canOpenFile:(NSString *)name
		 firstBlock:(NSData *)block
		 attributes:(NSDictionary *)attributes;

- (SEL)initLoader;
- (void)deallocLoader;
- (SEL)loadNextImage;
- (SEL)loadImage;

- (XeeBitmapImage *)currentImage;
@property (readonly) int currentHeight;

+ (void)load;
+ (NSArray *)fileTypes;

@end

#endif
