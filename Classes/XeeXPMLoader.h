#import "XeeBitmapImage.h"

@interface XeeXPMImage : XeeBitmapImage {
	int version;
}

+ (NSArray *)fileTypes;
+ (BOOL)canOpenFile:(NSString *)name
		 firstBlock:(NSData *)block
		 attributes:(NSDictionary *)attributes;
@property (class, readonly, copy)
	NSDictionary<NSString *, NSNumber *> *colourDictionary;

- (void)load;

- (NSString *)nextLine;
- (NSString *)nextString;

- (NSNumber *)parseHexColour:(NSString *)hex;

@end
