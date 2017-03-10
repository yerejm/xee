#import "SWFParser.h"
#import <XADMaster/CSFileHandle.h>
#import <XADMaster/CSZlibHandle.h>


NSString *SWFWrongMagicException=@"SWFWrongMagicException";
NSString *SWFNoMoreTagsException=@"SWFNoMoreTagsException";


@implementation SWFParser
@synthesize tag = currtag;
@synthesize tagLength = currlen;
@synthesize handle = fh;
@synthesize frame = currframe;
@synthesize version;
@synthesize rect;
@synthesize frames;
@synthesize framesPerSecond = fps;

+(SWFParser *)parserWithHandle:(CSHandle *)handle
{
	return [[SWFParser alloc] initWithHandle:handle];
}

+(SWFParser *)parserForPath:(NSString *)path
{
	CSFileHandle *handle=[CSFileHandle fileHandleForReadingAtPath:path];
	return [[self alloc] initWithHandle:handle];
}

-(id)initWithHandle:(CSHandle *)handle
{
	if (self=[super init]) {
		fh = handle;

		@try {
			[self parseHeader];
		}
		@catch(NSException *e) {
			@throw;
		}
	}
	return self;
}

-(void)parseHeader
{
	uint8_t magic[4];
	[fh readBytes:4 toBuffer:magic];

	version=magic[3];
	totallen=[fh readUInt32LE];

	if((magic[0]!='F'&&magic[0]!='C')||magic[1]!='W'||magic[2]!='S')
	[NSException raise:SWFWrongMagicException format:@"Not a Shockwave Flash file."];

	if (magic[0] == 'C') {
		CSZlibHandle *zh=[CSZlibHandle zlibHandleWithHandle:fh];
		fh = zh;
	}

	rect=SWFParseRect(fh);
	fps=[fh readUInt16LE];
	frames=[fh readUInt16LE];

	nexttag=[fh offsetInFile];

	currtag=0;
	currlen=0;
	currframe=0;
}

-(int)nextTag
{
	if(!nexttag) [NSException raise:SWFNoMoreTagsException format:@"No more tags available in the SWF file."];
	if(currtag==SWFShowFrameTag) currframe++;

	[fh seekToFileOffset:nexttag];

	int tagval=[fh readUInt16LE];

	currtag=tagval>>6;
	if(currtag==0)
	{
		nexttag=0;
		return 0;
	}

	currlen=tagval&0x3f;
	if(currlen==0x3f) currlen=[fh readUInt32LE];

	nexttag=[fh offsetInFile]+currlen;

	return currtag;
}

-(int)tagBytesLeft
{
	return (int)(nexttag-[fh offsetInFile]);
}
-(double)time
{
	return (double)currframe/((double)fps/256.0);
}

-(CSHandle *)tagHandle
{
	return [fh subHandleOfLength:[self tagBytesLeft]];
}

-(NSData *)tagContents
{
	return [fh readDataOfLength:[self tagBytesLeft]];
}

@end
