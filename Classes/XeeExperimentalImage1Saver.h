#import "XeeImageSaver.h"

@interface XeeExperimentalImage1Saver:XeeImageSaver

+(BOOL)canSaveImage:(XeeImage *)img;
-(id)initWithImage:(XeeImage *)img;
@property (readonly, copy) NSString *format;
@property (readonly, copy) NSString *extension;
-(BOOL)save:(NSString *)filename;

@end
