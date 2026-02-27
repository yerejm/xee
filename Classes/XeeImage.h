#import <Cocoa/Cocoa.h>

#import "XeeTypes.h"
#import "XeeFSRef.h"
#import "XeeProperties.h"

#include <pthread.h>

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

	// Coroutine replacement: a loader thread that can pause at yield points.
	pthread_mutex_t loadermutex;
	pthread_cond_t loadercond;
	BOOL loaderthreadstarted;
	unsigned int loaderthreadrunserial;
	BOOL loaderthreadpaused;
	BOOL loaderthreadexited;
	BOOL loaderthreadshouldexit;
	BOOL loaderthreadhasid;
	pthread_t loaderthread;

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

// These macros are used by loader implementations (including inside tight loops).
// They must behave like the old coroutine primitives:
// - HeaderDone: always yield back to the scheduler once header is available.
// - Yield: yield back only when stopLoading has been requested.
// - Done: mark finished and return control immediately.
#define XeeImageLoaderHeaderDone() [self _xeeLoaderHeaderDone]
#define XeeImageLoaderYield() [self _xeeLoaderYield]
#define XeeImageLoaderDone(success) [self _xeeLoaderDone:(success)]

@interface XeeImage (XeeLoaderControl)
// Private loader-control methods used by the macros above.
- (void)_xeeLoaderHeaderDone;
- (void)_xeeLoaderYield;
- (void)_xeeLoaderDone:(BOOL)success;
@end

@protocol XeeImageDelegate <NSObject>

- (void)xeeImageLoadingProgress:(XeeImage *)image;
- (void)xeeImageDidChange:(XeeImage *)image;
- (void)xeeImageSizeDidChange:(XeeImage *)image;
- (void)xeeImagePropertiesDidChange:(XeeImage *)image;

@end
