#import "XeeImageSaver.h"

@interface XeeCGImageSaver:XeeImageSaver

+(BOOL)canSaveImage:(XeeImage *)img;
+(BOOL)canSaveImageWithBitDepth:(int)depth floating:(BOOL)floating;
-(BOOL)save:(NSString *)filename;
@property (readonly, copy) NSString *type;
-(NSMutableDictionary *)properties;

@end

@interface XeeAlphaSaver:XeeCGImageSaver
{
	XeeSLSwitch *alpha;
}

-(id)initWithImage:(XeeImage *)img;
-(NSMutableDictionary *)properties;

@end



@interface XeePNGSaver:XeeAlphaSaver
{
    XeeSLSwitch *interlaced;
}

+(BOOL)canSaveImageWithBitDepth:(int)depth floating:(BOOL)floating;
-(id)initWithImage:(XeeImage *)img;
@property (readonly, copy) NSString *format;
@property (readonly, copy) NSString *extension;
@property (readonly, copy) NSString *type;
-(NSMutableDictionary *)properties;

@end

@interface XeeJPEGSaver:XeeCGImageSaver
{
    XeeSLSlider *quality;
}

-(id)initWithImage:(XeeImage *)img;
@property (readonly, copy) NSString *format;
@property (readonly, copy) NSString *extension;
@property (readonly, copy) NSString *type;
-(NSMutableDictionary *)properties;

@end

@interface XeeJP2Saver:XeeAlphaSaver
{
	XeeSLSlider *quality;
}

-(id)initWithImage:(XeeImage *)img;
@property (readonly, copy) NSString *format;
@property (readonly, copy) NSString *extension;
@property (readonly, copy) NSString *type;
-(NSMutableDictionary *)properties;

@end

@interface XeeTIFFSaver:XeeAlphaSaver
{
	XeeSLPopUp *compression;
}

+(BOOL)canSaveImageWithBitDepth:(int)depth floating:(BOOL)floating;
-(id)initWithImage:(XeeImage *)img;
@property (readonly, copy) NSString *format;
@property (readonly, copy) NSString *extension;
@property (readonly, copy) NSString *type;
-(NSMutableDictionary *)properties;
@end



@interface XeePhotoshopSaver:XeeAlphaSaver
+(BOOL)canSaveImageWithBitDepth:(int)depth floating:(BOOL)floating;
@property (readonly, copy) NSString *format;
@property (readonly, copy) NSString *extension;
@property (readonly, copy) NSString *type;
@end

@interface XeeOpenEXRSaver:XeeCGImageSaver
+(BOOL)canSaveImageWithBitDepth:(int)depth floating:(BOOL)floating;
@property (readonly, copy) NSString *format;
@property (readonly, copy) NSString *extension;
@property (readonly, copy) NSString *type;
@end



@interface XeeGIFSaver:XeeAlphaSaver
@property (readonly, copy) NSString *format;
@property (readonly, copy) NSString *extension;
@property (readonly, copy) NSString *type;
@end

@interface XeePICTSaver:XeeAlphaSaver
@property (readonly, copy) NSString *format;
@property (readonly, copy) NSString *extension;
@property (readonly, copy) NSString *type;
@end

@interface XeeBMPSaver:XeeCGImageSaver
@property (readonly, copy) NSString *format;
@property (readonly, copy) NSString *extension;
@property (readonly, copy) NSString *type;
-(NSMutableDictionary *)properties;
@end

@interface XeeTGASaver:XeeAlphaSaver
@property (readonly, copy) NSString *format;
@property (readonly, copy) NSString *extension;
@property (readonly, copy) NSString *type;
@end

@interface XeeSGISaver:XeeAlphaSaver
@property (readonly, copy) NSString *format;
@property (readonly, copy) NSString *extension;
@property (readonly, copy) NSString *type;
@end
