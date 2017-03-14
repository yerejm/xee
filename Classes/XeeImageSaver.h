#import <Cocoa/Cocoa.h>

#import "XeeImage.h"
#import "XeeSimpleLayout.h"

@interface XeeImageSaver:NSObject
{
	XeeImage *image;
	XeeSLControl *control;
}

+(BOOL)canSaveImage:(XeeImage *)img;
+(NSArray<__kindof XeeImageSaver*> *)saversForImage:(XeeImage *)img;
+(void)registerSaverClass:(Class)saverclass;

-(instancetype)initWithImage:(XeeImage *)img;
@property (readonly, copy) NSString *format;
@property (readonly, copy) NSString *extension;
-(BOOL)save:(NSString *)filename;
@property (retain) XeeSLControl *control;

@end
