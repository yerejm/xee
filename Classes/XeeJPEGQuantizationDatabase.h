#import <Cocoa/Cocoa.h>

#include "libjpeg/jpeglib.h"
@class XeePropertyItem;

@interface XeeJPEGQuantizationDatabase:NSObject
{
	NSMutableDictionary *dict;
}

@property (class, readonly, retain) XeeJPEGQuantizationDatabase *defaultDatabase;

-(instancetype)initWithFile:(NSString *)filename;

-(NSArray *)producersForTables:(struct jpeg_decompress_struct *)cinfo;
-(NSArray *)producersForTableString:(NSString *)tables;

-(NSArray<XeePropertyItem*> *)propertyArrayForTables:(struct jpeg_decompress_struct *)cinfo;

@end
