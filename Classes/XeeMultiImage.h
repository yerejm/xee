#import "XeeImage.h"



@interface XeeMultiImage:XeeImage <XeeImageDelegate>
{
	NSMutableArray *subimages;
	NSInteger currindex;
	XeeImage *currloading;
}

-(id)init;
-(void)dealloc;

-(void)addSubImage:(XeeImage *)subimage;
-(void)addSubImages:(NSArray *)array;

-(void)xeeImageLoadingProgress:(XeeImage *)image;
-(void)xeeImageDidChange:(XeeImage *)image;
-(void)xeeImageSizeDidChange:(XeeImage *)image;
-(void)xeeImagePropertiesDidChange:(XeeImage *)image;

-(XeeImage *)currentSubImage;

/*-(BOOL)loaded;
-(BOOL)failed;
-(BOOL)needsLoading;*/
-(void)stopLoading;

-(void)runLoaderOnSubImage:(XeeImage *)image;

@property (readonly) NSInteger frames;
@property (nonatomic) NSInteger frame;

-(NSRect)updatedAreaInRect:(NSRect)rect;
-(void)drawInRect:(NSRect)rect bounds:(NSRect)bounds lowQuality:(BOOL)lowquality;

-(CGImageRef)createCGImage CF_RETURNS_RETAINED;
@property (readonly) XeeSaveFormatFlags losslessSaveFlags;
@property (readonly, copy) NSString *losslessFormat;
@property (readonly, copy) NSString *losslessExtension;
-(BOOL)losslessSaveTo:(NSString *)path flags:(XeeSaveFormatFlags)flags;

@property (readonly) int width;
@property (readonly) int height;
@property (readonly) int fullWidth;
@property (readonly) int fullHeight;
//@property (readonly, copy) NSString *depth;
//@property (readonly, retain) NSImage *depthIcon;
@property (readonly) BOOL transparent;
@property (readonly) NSColor *backgroundColor;
@property (nonatomic) NSRect croppingRect;
@property (nonatomic) XeeTransformation orientation;
@property (nonatomic) XeeTransformation correctOrientation;

-(NSArray *)properties;

-(void)resetTransformations;

@end
