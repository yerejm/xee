#import "XeeFileSource.h"
#import "PDFStream.h"

@interface XeePDFSource:XeeListSource
{
	NSString *filename;
	PDFParser *parser;
}

+(NSArray *)fileTypes;

-(instancetype)initWithFile:(NSString *)pdfname;

@property (readonly, retain) NSString *windowTitle;
@property (readonly, retain) NSString *windowRepresentedFilename;
@property (readonly) BOOL canBrowse;

@end

@interface XeePDFEntry:XeeListEntry
{
	PDFStream *object;
	NSString *name;
	BOOL complained;
}

-(instancetype)initWithPDFStream:(PDFStream *)stream name:(NSString *)descname;

@property (readonly, copy) NSString *descriptiveName;
-(XeeImage *)produceImage;

@end
