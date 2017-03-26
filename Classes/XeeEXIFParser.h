#import <Cocoa/Cocoa.h>
#import "XeeParser.h"

#import "XeeTypes.h"
#import "exiftags/exif.h"

@class XeePropertyItem;

// Tags and tag sets

typedef NS_ENUM(int16_t, XeeEXIFTag) {
	XeeOrientationTag = 0x0112,
	XeeThumbnailOffsetTag = 0x0201,
	XeeThumbnailLengthTag = 0x0202,
	XeeFocalPlaneXResolution = (int16_t)0xa20e,
	XeeFocalPlaneYResolution = (int16_t)0xa20f

};

typedef enum { XeeStandardTagSet }
XeeEXIFTagSet;

// Rationals

typedef struct {
	int num, denom;
} XeeRational;

static inline XeeRational XeeMakeRational(int num, int denom)
{
	XeeRational res = {num, denom};
	return res;
}
static inline int XeeRationalNumerator(XeeRational r)
{
	return r.num;
}
static inline int XeeRationalDenominator(XeeRational r)
{
	return r.denom;
}

#define XeeZeroRational XeeMakeRational(0, 1);

// Reader class

@interface XeeEXIFParser : NSObject <XeeParser> {
	struct exiftags *exiftags;
	uint8_t *data;
	NSData *dataobj;
}

- (instancetype)initWithBuffer:(const uint8_t *)exifdata length:(int)len;
- (instancetype)initWithBuffer:(uint8_t *)exifdata
						length:(int)len
					   mutable:(BOOL) mutable;
- (instancetype)initWithData:(NSData *)data;

- (NSString *)stringForTag:(XeeEXIFTag)tag set:(XeeEXIFTagSet)set;
- (int)integerForTag:(XeeEXIFTag)tag set:(XeeEXIFTagSet)set;
- (XeeRational)rationalForTag:(XeeEXIFTag)tag set:(XeeEXIFTagSet)set;
- (BOOL)setShort:(int)val forTag:(XeeEXIFTag)tag set:(XeeEXIFTagSet)set;
- (BOOL)setLong:(int)val forTag:(XeeEXIFTag)tag set:(XeeEXIFTagSet)set;
- (BOOL)setRational:(XeeRational)val
			 forTag:(XeeEXIFTag)tag
				set:(XeeEXIFTagSet)set;
- (struct exifprop *)exifPropForTag:(XeeEXIFTag)tag set:(XeeEXIFTagSet)set;

- (NSArray<XeePropertyItem *> *)propertyArray;

@end
