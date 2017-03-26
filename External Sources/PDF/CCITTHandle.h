#import <XADMaster/CSByteStreamHandle.h>
#import <XADMaster/XADPrefixCode.h>
#import "PDFNameCollisionPreventer.h"

extern NSString *CCITTCodeException;

@interface CCITTFaxHandle : CSByteStreamHandle {
	int cols, white;
	int col, colour, bitsleft;
}

- (instancetype)initWithHandle:(CSHandle *)handle
					   columns:(int)columns
						 white:(int)whitevalue;

- (void)resetByteStream;
- (uint8_t)produceByteAtOffset:(off_t)pos;

- (void)startNewLine;
- (void)findNextSpanLength;

@end

@interface CCITTFaxT6Handle : CCITTFaxHandle {
	int *prevchanges, numprevchanges;
	int *currchanges, numcurrchanges;
	int prevpos, previndex, currpos, currcol, nexthoriz;
	XADPrefixCode *maincode, *whitecode, *blackcode;
}

- (instancetype)initWithHandle:(CSHandle *)handle
					   columns:(int)columns
						 white:(int)whitevalue;

- (void)resetByteStream;
- (void)startNewLine;
- (void)findNextSpanLength;

@end
