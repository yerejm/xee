#import <Cocoa/Cocoa.h>

#import "XeeTypes.h"
#import "XeeFSRef.h"
#import "XeeProperties.h"

#import <XADMaster/CSFileHandle.h>

typedef NS_OPTIONS(unsigned int, XeeSaveFormatFlags) {
	XeeCanSaveLosslesslyFlag = 1,
	XeeCanOverwriteLosslesslyFlag = 2,
	XeeNotActuallyLosslessFlag = 4,
	XeeCroppingIsInexactFlag = 8,
	XeeHasUntransformableBlocksFlag = 16,
	XeeUntransformableBlocksCanBeRetainedFlag = 32
};

#define XeeTrimCroppingFlag 1
#define XeeRetainUntransformableBlocksFlag 2

//#define Xee
@protocol XeeImageDelegate;

@interface XeeImage : NSObject {
	CSHandle *handle;
	XeeFSRef *ref;
	NSDictionary *attrs;

	SEL nextselector;
	BOOL finished, loaded, thumbonly;
	volatile BOOL stop;

	NSString *format;
	NSInteger width, height;
	NSString *depth;
	NSImage *icon, *depthicon;
	BOOL transparent;
	NSColor *back;
	XeeTransformation orientation, correctorientation;
	NSInteger crop_x, crop_y, crop_width, crop_height;
	NSMutableArray *properties;

	__unsafe_unretained id<XeeImageDelegate> delegate;
}

- (instancetype)init NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithHandle:(CSHandle *)fh;
- (instancetype)initWithHandle:(CSHandle *)fh
						   ref:(XeeFSRef *)fsref
					attributes:(NSDictionary *)attributes;
- (instancetype)initWithHandle2:(CSHandle *)fh
							ref:(XeeFSRef *)fsref
					 attributes:(NSDictionary *)attributes;

- (SEL)initLoader;
- (void)deallocLoader;

- (void)runLoader;
- (void)runLoaderForThumbnail;

- (void)runLoader2;
- (void)load;

@property (readonly) BOOL loaded;
@property (readonly) BOOL failed;
@property (readonly) BOOL needsLoading;
- (void)stopLoading;
@property (readonly) BOOL hasBeenStopped;
@property (readonly) CSHandle *handle;
@property (readonly) CSFileHandle *fileHandle;
- (CSHandle *)handle;
- (CSFileHandle *)fileHandle;

@property (readonly) NSInteger frames;
@property (nonatomic) NSInteger frame;

@property (assign) id<XeeImageDelegate> delegate;
- (void)triggerLoadingAction;
- (void)triggerChangeAction;
- (void)triggerSizeChangeAction;
- (void)triggerPropertyChangeAction;

@property (readonly) BOOL animated;
@property (nonatomic) BOOL animating;
- (void)setAnimatingDefault;

- (NSRect)updatedAreaInRect:(NSRect)rect;

- (void)drawInRect:(NSRect)rect bounds:(NSRect)bounds;
- (void)drawInRect:(NSRect)rect
			bounds:(NSRect)bounds
		lowQuality:(BOOL)lowquality;

- (CGImageRef)createCGImage CF_RETURNS_RETAINED;

@property (readonly) XeeSaveFormatFlags losslessSaveFlags;
@property (readonly, copy) NSString *losslessFormat;
@property (readonly, copy) NSString *losslessExtension;
- (BOOL)losslessSaveTo:(NSString *)path flags:(XeeSaveFormatFlags)flags;

@property (readonly, retain) XeeFSRef *ref;
@property (readonly) NSString *filename;
@property (nonatomic, copy) NSString *format;
@property (nonatomic, retain) NSImage *icon;
@property (readonly) NSInteger width;
@property (readonly) NSInteger height;
@property (readonly) NSInteger fullWidth;
@property (readonly) NSInteger fullHeight;
@property (nonatomic, copy) NSString *depth;
@property (nonatomic, retain) NSImage *depthIcon;
@property (readonly) BOOL transparent;
@property (nonatomic, retain) NSColor *backgroundColor;

@property (nonatomic) XeeTransformation orientation;
@property (nonatomic) XeeTransformation correctOrientation;
@property (nonatomic) NSRect croppingRect;
@property (readonly) NSRect rawCroppingRect;
@property (readonly, getter=isTransformed) BOOL transformed;
@property (readonly, getter=isCropped) BOOL cropped;
@property (readonly) XeeMatrix transformationMatrix;
@property (nonatomic, retain) NSArray *properties;
- (XeeMatrix)transformationMatrixInRect:(NSRect)rect;

- (NSArray *)properties;

@property (readonly, retain) NSDictionary<NSFileAttributeKey, id> *attributes;
@property (readonly) uint64_t fileSize;
@property (readonly) NSDate *date;
@property (readonly, copy) NSString *descriptiveFilename;

//-(void)setFilename:(NSString *)name;
- (void)setFormat:(NSString *)fmt;
- (void)setBackgroundColor:(NSColor *)col;
- (void)setProperties:(NSArray *)newproperties;

- (void)setOrientation:(XeeTransformation)transformation;
- (void)setCorrectOrientation:(XeeTransformation)transformation;
- (void)setCroppingRect:(NSRect)rect;
- (void)resetTransformations;

- (void)setDepth:(NSString *)d;
- (void)setDepthIcon:(NSImage *)icon;
- (void)setDepthIconName:(NSImageName)iconname;
- (void)setDepth:(NSString *)d iconName:(NSImageName)iconname;

- (void)setDepthBitmap;
- (void)setDepthIndexed:(int)colors;
- (void)setDepthGrey:(int)bits alpha:(BOOL)alpha floating:(BOOL)floating;
- (void)setDepthRGB:(int)bits alpha:(BOOL)alpha floating:(BOOL)floating;
- (void)setDepthCMYK:(int)bits alpha:(BOOL)alpha;
- (void)setDepthLab:(int)bits alpha:(BOOL)alpha;
- (void)setDepthGrey:(int)bits;
- (void)setDepthRGB:(int)bits;
- (void)setDepthRGBA:(int)bits;

+ (XeeImage *)imageForFilename:(NSString *)filename;
+ (XeeImage *)imageForRef:(XeeFSRef *)ref;
+ (XeeImage *)imageForHandle:(CSHandle *)fh;
+ (XeeImage *)imageForHandle:(CSHandle *)fh
						 ref:(XeeFSRef *)ref
				  attributes:(NSDictionary<NSFileAttributeKey, id> *)attrs;
@property (class, readonly) NSArray<NSString *> *allFileTypes;
@property (class, readonly) NSDictionary *fileTypeDictionary;
+ (void)registerImageClass:(Class)aClass;

+ (BOOL)canOpenFile:(NSString *)name
		 firstBlock:(NSData *)block
		 attributes:(NSDictionary<NSFileAttributeKey, id> *)attributes;
@property (class, readonly) NSArray<NSString *> *fileTypes;

@end

static inline void __XeeImageLoaderYield(volatile BOOL *stop)
{
	if (*stop) {
		*stop = NO;
	}
}
static inline void __XeeImageLoaderDone(BOOL success, BOOL *loaded,
										BOOL *finished)
{
	*loaded = success;
	*finished = YES;
}
#define XeeImageLoaderHeaderDone()
#define XeeImageLoaderYield() __XeeImageLoaderYield(&stop)
#define XeeImageLoaderDone(success) __XeeImageLoaderDone(success, &loaded, &finished)

@protocol XeeImageDelegate <NSObject>

- (void)xeeImageLoadingProgress:(XeeImage *)image;
- (void)xeeImageDidChange:(XeeImage *)image;
- (void)xeeImageSizeDidChange:(XeeImage *)image;
- (void)xeeImagePropertiesDidChange:(XeeImage *)image;

@end
