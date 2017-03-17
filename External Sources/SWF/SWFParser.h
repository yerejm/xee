#import <Foundation/Foundation.h>

#import <XADMaster/XADSWFGeometry.h>

#import <XADMaster/CSHandle.h>

#define SWFEndTag 0
#define SWFShowFrameTag 1
#define SWFDefineShapeTag 2
#define SWFPlaceObjectTag 4
#define SWFRemoveObjectTag 5
#define SWFDefineBitsJPEGTag 6
#define SWFJPEGTables 8
#define SWFDefineTextTag 11
#define SWFDefineFontInfoTag 13
#define SWFDefineSoundTag 14
#define SWFSoundStreamHeadTag 18
#define SWFSoundStreamBlockTag 19
#define SWFDefineBitsLosslessTag 20
#define SWFDefineBitsJPEG2Tag 21
#define SWFPlaceObject2Tag 26
#define SWFRemoveObject2Tag 28
#define SWFDefineText2Tag 33
#define SWFDefineBitsJPEG3Tag 35
#define SWFDefineBitsLossless2Tag 36
#define SWFSoundStreamHead2Tag 45
#define SWFDefineFont2Tag 48
#define SWFPlaceObject3Tag 70
#define SWFDefineFont3Tag 75

//extern NSString *SWFWrongMagicException;
//extern NSString *SWFNoMoreTagsException;

@interface SWFParser:NSObject
{
	CSHandle *fh;
	off_t nexttag;

	int totallen,version;
	SWFRect rect;
	int frames,fps;

	int currtag,currlen;
	int currframe;
}

+(instancetype)parserWithHandle:(CSHandle *)handle;
+(instancetype)parserForPath:(NSString *)path;

-(instancetype)initWithHandle:(CSHandle *)handle;

-(void)parseHeader;

@property (readonly) int version;
@property (readonly) SWFRect rect;
@property (readonly) int frames;
@property (readonly) int framesPerSecond;

-(int)nextTag;

@property (readonly) int tag;
@property (readonly) int tagLength;
@property (readonly) int tagBytesLeft;
@property (readonly) int frame;
@property (readonly) double time;

@property (readonly, strong) CSHandle *handle;
-(CSHandle *)tagHandle;
-(NSData *)tagContents;

@end
