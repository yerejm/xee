#import "XeeBitmapImage.h"

@class XeeIFFHandle;
@class XeeILBMRange;
@class XeePropertyItem;

@interface XeeILBMImage : XeeBitmapImage {
	XeeIFFHandle *iff;

	int realwidth, realheight;
	int planes, masking, compression, trans;
	int xasp, yasp, xscale, yscale;
	int rowbytes;

	BOOL ham, ham8, ehb, ocscol, transparency;

	uint8_t *image;
	uint8_t *mask;

	uint32_t palette[256];

	NSMutableArray<XeeILBMRange *> *ranges;
	NSMutableArray<XeePropertyItem *> *comments;

	int current_line;

	int clock;
	NSTimer *animationtimer;
}

+ (NSArray *)fileTypes;
+ (BOOL)canOpenFile:(NSString *)name
		 firstBlock:(NSData *)block
		 attributes:(NSDictionary *)attributes;

- (instancetype)init;

- (SEL)initLoader;
- (void)deallocLoader;
- (SEL)loadChunk;
- (SEL)startLoadingImage;
- (SEL)loadPaletteImage;
- (SEL)loadRGBImage;

- (void)readRow:(uint8_t *)row;
- (void)renderImage;
- (void)addCommentWithLabel:(NSString *)label data:(NSData *)commentdata;

@property (readonly) uint32_t *palette NS_RETURNS_INNER_POINTER;

@property (readonly) BOOL animated;
@property (nonatomic) BOOL animating;

@end

@interface XeeILBMRange : NSObject {
	int num;
	uint32_t *colours;
	int *indexes;

	float interval;
	float next;

	__unsafe_unretained XeeILBMImage *image;
}

- (instancetype)initWithIFF:(XeeIFFHandle *)iff image:(XeeILBMImage *)image;
- (BOOL)allocBuffers:(int)length;
- (void)setIndexesFrom:(int)start to:(int)end reverse:(BOOL)reverse;
- (void)setup;
- (BOOL)triggerCheck:(float)time;
- (void)cycle;

@end
