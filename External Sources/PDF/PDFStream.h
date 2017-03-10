#import <Foundation/Foundation.h>

#import "NSDictionaryNumberExtension.h"

#import <XADMaster/CSHandle.h>
#import <XADMaster/CSByteStreamHandle.h>
#import "PDFNameCollisionPreventer.h"

@class PDFParser,PDFObjectReference;

@interface PDFStream:NSObject
{
	NSDictionary *dict;
	CSHandle *fh;
	off_t offs;
	PDFObjectReference *ref;
	PDFParser *parser;
}

-(id)initWithDictionary:(NSDictionary *)dictionary fileHandle:(CSHandle *)filehandle
reference:(PDFObjectReference *)reference parser:(PDFParser *)owner;
-(void)dealloc;

-(NSDictionary *)dictionary;
-(PDFObjectReference *)reference;

@property (readonly, getter=isImage) BOOL image;
@property (readonly, getter=isJPEG) BOOL JPEG;
@property (readonly, getter=isJPEG2000) BOOL JPEG2000;
@property (readonly, getter=isMask) BOOL mask;
@property (readonly, getter=isBitmap) BOOL bitmap;
@property (readonly, getter=isIndexed) BOOL indexed;
@property (readonly, getter=isGrey) BOOL grey;
@property (readonly, getter=isRGB) BOOL RGB;
@property (readonly, getter=isCMYK) BOOL CMYK;
@property (readonly, getter=isLab) BOOL lab;
-(NSString *)finalFilter;
-(int)bitsPerComponent;

-(NSString *)colourSpaceOrAlternate;
-(NSString *)subColourSpaceOrAlternate;
-(NSString *)_parseColourSpace:(id)colourspace;
@property (readonly) int numberOfColours;
-(NSData *)paletteData;
-(NSArray *)decodeArray;

-(CSHandle *)rawHandle;
-(CSHandle *)handle;
-(CSHandle *)JPEGHandle;
-(CSHandle *)handleExcludingLast:(BOOL)excludelast;
-(CSHandle *)handleForFilterName:(NSString *)filtername decodeParms:(NSDictionary *)decodeparms parentHandle:(CSHandle *)parent;
-(CSHandle *)predictorHandleForDecodeParms:(NSDictionary *)decodeparms parentHandle:(CSHandle *)parent;

@end

@interface PDFASCII85Handle:CSByteStreamHandle
{
	uint32_t val;
	BOOL finalbytes;
}

-(void)resetByteStream;
-(uint8_t)produceByteAtOffset:(off_t)pos;

@end

@interface PDFHexHandle:CSByteStreamHandle

-(uint8_t)produceByteAtOffset:(off_t)pos;

@end




@interface PDFTIFFPredictorHandle:CSByteStreamHandle
{
	int cols,comps,bpc;
	int prev[4];
}

-(instancetype)initWithHandle:(CSHandle *)handle columns:(int)columns
components:(int)components bitsPerComponent:(int)bitspercomp;
-(uint8_t)produceByteAtOffset:(off_t)pos;

@end

@interface PDFPNGPredictorHandle:CSByteStreamHandle
{
	int cols,comps,bpc;
	uint8_t *prevbuf;
	int type;
}

-(instancetype)initWithHandle:(CSHandle *)handle columns:(int)columns
components:(int)components bitsPerComponent:(int)bitspercomp;
-(void)resetByteStream;
-(uint8_t)produceByteAtOffset:(off_t)pos;

@end
