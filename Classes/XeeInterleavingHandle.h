#import <XADMaster/CSHandle.h>

@interface XeeInterleavingHandle : CSHandle {
	NSArray<CSHandle *> *handles;
	int n2, bits;
}

- (instancetype)initWithHandles:(NSArray<CSHandle *> *)handlearray
					elementSize:(int)bitsize;

//-(off_t)fileSize;
//-(off_t)offsetInFile;
//-(BOOL)atEndOfFile;
//-(void)seekToFileOffset:(off_t)offs;
//-(void)seekToEndOfFile;
- (int)readAtMost:(int)num toBuffer:(void *)buffer;
//-(id)copyWithZone:(NSZone *)zone;

@end
