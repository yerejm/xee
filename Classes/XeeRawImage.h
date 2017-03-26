#import "XeeBitmapImage.h"

typedef NS_ENUM(NSInteger, XeeRawColourSpace) {
	XeeGreyRawColourSpace = 1,
	XeeRGBRawColourSpace = 2,
	XeeCMYKRawColourSpace = 3,
	XeeLabRawColourSpace = 4,
};

typedef NS_OPTIONS(unsigned int, XeeRawAlphaFlags) {
	XeeAlphaFirstRawFlag = 0x0001,
	XeeAlphaLastRawFlag = 0x0002,
	XeeNoAlphaRawFlag = 0x0000,
	XeeSkipAlphaRawFlag = 0x0004,
	XeeAlphaPremultipliedRawFlag = 0x0004,
	XeeAlphaPrecomposedRawFlag = 0x0010,
	XeeBigEndianRawFlag = 0x0020,
	XeeLittleEndianRawFlag = 0x0000,
	XeeFloatingPointRawFlag = 0x0040,
};

@interface XeeRawImage : XeeBitmapImage {
	int bitdepth, inbpr, channels, uncomposition, transformation, type;
	uint8_t *buffer;
	BOOL flipendian, needsbuffer, adjustranges;
	float range[5][2];
}

- (id)initWithHandle:(CSHandle *)inhandle
			   width:(int)framewidth
			  height:(int)frameheight
			   depth:(int)framedepth
		 colourSpace:(XeeRawColourSpace)space
			   flags:(XeeRawAlphaFlags)flags;
- (id)initWithHandle:(CSHandle *)inhandle
			   width:(int)framewidth
			  height:(int)frameheight
			   depth:(int)framedepth
		 colourSpace:(XeeRawColourSpace)space
			   flags:(XeeRawAlphaFlags)flags
		 bytesPerRow:(int)byterperinputrow;
- (void)dealloc;

- (void)setZeroPoint:(float)low onePoint:(float)high forChannel:(int)channel;

- (void)load;

@end
