#import "XeeBitmapImage.h"

#import "libungif/gif_lib.h"

@class XeeGIFFrame,XeeGIFPalette;

@interface XeeGIFImage:XeeBitmapImage
{
	GifFileType *gif;

	NSMutableArray *frames;
	NSMutableArray *comments;

	int background;
	NSInteger currframe;
	int frametime,transindex,disposal;
	BOOL backupneeded;
	uint32_t *backup;
	XeeGIFPalette *globalpal;

	int animticks;
	NSTimer *animationtimer;
}

+(NSArray *)fileTypes;
+(BOOL)canOpenFile:(NSString *)name firstBlock:(NSData *)block attributes:(NSDictionary *)attributes;

-(instancetype)init;

-(SEL)initLoader;
-(void)deallocLoader;
-(SEL)startLoading;
-(SEL)loadRecord;
-(SEL)failLoading;
-(SEL)finishLoading;

@property (readonly) NSInteger frames;
@property (nonatomic) NSInteger frame;
-(void)animate:(NSTimer *)timer;

@property (readonly) BOOL animated;
@property (nonatomic) BOOL animating;
-(void)setAnimatingDefault;

-(void)clearImage;
-(int)background;
@property (readonly) uint32_t *backup NS_RETURNS_INNER_POINTER;

@end



@interface XeeGIFFrame:NSObject
{
	int left,top,width,height;
	int time,transparent,disposal;
	XeeGIFPalette *palette;

	unsigned char *data;
}

-(instancetype)initWithWidth:(int)framewidth height:(int)frameheight left:(int)frameleft top:(int)frametop time:(int)frametime transparent:(int)trans disposal:(int)disp palette:(XeeGIFPalette *)pal;

-(void)draw:(XeeGIFImage *)image;
-(void)dispose:(XeeGIFImage *)image;
-(void)drawAndDispose:(XeeGIFImage *)image;

@property (readonly) unsigned char *data NS_RETURNS_INNER_POINTER;
-(int)time;

@end


@interface XeeGIFPalette:NSObject
{
	uint32_t table[256];
}

-(instancetype)initWithColorMap:(ColorMapObject *)cmap;
@property (readonly) uint32_t *table NS_RETURNS_INNER_POINTER;

@end
