#import <Cocoa/Cocoa.h>

#import "XeeTypes.h"
//TODO: port to GCD/libdispatch or NSOperation?
#import "CSCoroutine.h"
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

@interface XeeImage:NSObject
{
	CSHandle *handle;
	XeeFSRef *ref;
	NSDictionary *attrs;

	SEL nextselector;
	BOOL finished,loaded,thumbonly;
	volatile BOOL stop;

	CSCoroutine *coro;

	NSString *format;
	int width,height;
	NSString *depth;
	NSImage *icon,*depthicon;
	BOOL transparent;
	NSColor *back;
	XeeTransformation orientation,correctorientation;
	int crop_x,crop_y,crop_width,crop_height;
	NSMutableArray *properties;

	id<XeeImageDelegate> delegate;
}

-(instancetype)init;
-(instancetype)initWithHandle:(CSHandle *)fh;
-(instancetype)initWithHandle:(CSHandle *)fh ref:(XeeFSRef *)fsref attributes:(NSDictionary *)attributes;
-(instancetype)initWithHandle2:(CSHandle *)fh ref:(XeeFSRef *)fsref attributes:(NSDictionary *)attributes;

-(SEL)initLoader;
-(void)deallocLoader;

-(void)runLoader;
-(void)runLoaderForThumbnail;

-(void)runLoader2;
-(void)load;

@property (readonly) BOOL loaded;
@property (readonly) BOOL failed;
@property (readonly) BOOL needsLoading;
-(void)stopLoading;
@property (readonly) BOOL hasBeenStopped;
@property (readonly) CSHandle *handle;
@property (readonly) CSFileHandle *fileHandle;
-(CSHandle *)handle;
-(CSFileHandle *)fileHandle;

@property (readonly) NSInteger frames;
@property (nonatomic) NSInteger frame;

@property (assign) id<XeeImageDelegate> delegate;
-(void)triggerLoadingAction;
-(void)triggerChangeAction;
-(void)triggerSizeChangeAction;
-(void)triggerPropertyChangeAction;

@property (readonly) BOOL animated;
@property (nonatomic) BOOL animating;
-(void)setAnimatingDefault;

-(NSRect)updatedAreaInRect:(NSRect)rect;

-(void)drawInRect:(NSRect)rect bounds:(NSRect)bounds;
-(void)drawInRect:(NSRect)rect bounds:(NSRect)bounds lowQuality:(BOOL)lowquality;

-(CGImageRef)createCGImage CF_RETURNS_RETAINED;

@property (readonly) XeeSaveFormatFlags losslessSaveFlags;
@property (readonly, copy) NSString *losslessFormat;
@property (readonly, copy) NSString *losslessExtension;
-(BOOL)losslessSaveTo:(NSString *)path flags:(XeeSaveFormatFlags)flags;

@property (readonly, retain) XeeFSRef *ref;
@property (readonly) NSString *filename;
@property (nonatomic, copy) NSString *format;
@property (nonatomic, retain) NSImage *icon;
@property (readonly) int width;
@property (readonly) int height;
@property (readonly) int fullWidth;
@property (readonly) int fullHeight;
@property (nonatomic, copy) NSString *depth;
@property (nonatomic, retain) NSImage *depthIcon;
@property (readonly) BOOL transparent;
@property (readonly) NSColor *backgroundColor;

@property (readonly) XeeTransformation orientation;
@property (readonly) XeeTransformation correctOrientation;
@property (readonly) NSRect croppingRect;
@property (readonly) NSRect rawCroppingRect;
@property (readonly, getter=isTransformed) BOOL transformed;
@property (readonly, getter=isCropped) BOOL cropped;
@property (readonly) XeeMatrix transformationMatrix;
-(XeeMatrix)transformationMatrixInRect:(NSRect)rect;

-(NSArray *)properties;

-(NSDictionary *)attributes;
@property (readonly) uint64_t fileSize;
@property (readonly) NSDate *date;
@property (readonly, copy) NSString *descriptiveFilename;

//-(void)setFilename:(NSString *)name;
-(void)setFormat:(NSString *)fmt;
-(void)setBackgroundColor:(NSColor *)col;
-(void)setProperties:(NSArray *)newproperties;

-(void)setOrientation:(XeeTransformation)transformation;
-(void)setCorrectOrientation:(XeeTransformation)transformation;
-(void)setCroppingRect:(NSRect)rect;
-(void)resetTransformations;

-(void)setDepth:(NSString *)d;
-(void)setDepthIcon:(NSImage *)icon;
-(void)setDepthIconName:(NSString *)iconname;
-(void)setDepth:(NSString *)d iconName:(NSString *)iconname;

-(void)setDepthBitmap;
-(void)setDepthIndexed:(int)colors;
-(void)setDepthGrey:(int)bits alpha:(BOOL)alpha floating:(BOOL)floating;
-(void)setDepthRGB:(int)bits alpha:(BOOL)alpha floating:(BOOL)floating;
-(void)setDepthCMYK:(int)bits alpha:(BOOL)alpha;
-(void)setDepthLab:(int)bits alpha:(BOOL)alpha;
-(void)setDepthGrey:(int)bits;
-(void)setDepthRGB:(int)bits;
-(void)setDepthRGBA:(int)bits;

-(NSString*)description;

+(XeeImage *)imageForFilename:(NSString *)filename;
+(XeeImage *)imageForRef:(XeeFSRef *)ref;
+(XeeImage *)imageForHandle:(CSHandle *)fh;
+(XeeImage *)imageForHandle:(CSHandle *)fh ref:(XeeFSRef *)ref attributes:(NSDictionary *)attrs;
@property (class, readonly) NSArray<NSString*> *allFileTypes;
+(NSDictionary *)fileTypeDictionary;
+(void)registerImageClass:(Class)class;

+(BOOL)canOpenFile:(NSString *)name firstBlock:(NSData *)block attributes:(NSDictionary *)attributes;
@property (class, readonly) NSArray<NSString*> *fileTypes;

@end

static inline void __XeeImageLoaderYield(volatile BOOL *stop,CSCoroutine *coro) { if(*stop) { *stop=NO; [coro returnFrom]; } }
static inline void __XeeImageLoaderDone(BOOL success,BOOL *loaded,BOOL *finished,CSCoroutine *coro) { *loaded=success; *finished=YES; for(;;) [coro returnFrom]; }
#define XeeImageLoaderHeaderDone() [coro returnFrom]
#define XeeImageLoaderYield() __XeeImageLoaderYield(&stop,coro)
#define XeeImageLoaderDone(success) __XeeImageLoaderDone(success,&loaded,&finished,coro)



@protocol XeeImageDelegate <NSObject>

-(void)xeeImageLoadingProgress:(XeeImage *)image;
-(void)xeeImageDidChange:(XeeImage *)image;
-(void)xeeImageSizeDidChange:(XeeImage *)image;
-(void)xeeImagePropertiesDidChange:(XeeImage *)image;

@end
