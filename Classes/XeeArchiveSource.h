#import "XeeFileSource.h"

#import <XADMaster/XADArchive.h>

@interface XeeArchiveSource : XeeFileSource {
	NSString *filename;
	XADArchiveParser *parser;
	NSString *tmpdir;
	int n;
}

+ (NSArray *)fileTypes;

- (instancetype)initWithArchive:(NSString *)archivename;
- (void)dealloc;

- (void)start;

- (NSString *)windowTitle;
- (NSString *)windowRepresentedFilename;

- (BOOL)canBrowse;
- (BOOL)canSort;
- (BOOL)canCopyCurrentImage;

@end

@interface XeeArchiveEntry : XeeFileEntry {
	XADArchiveParser *parser;
	NSDictionary *dict;
	XeeFSRef *ref;
	NSString *path;
	uint64_t size;
	double time;
}

- (instancetype)initWithArchiveParser:(XADArchiveParser *)parent
								entry:(NSDictionary *)entry
							 realPath:(NSString *)realpath;
- (instancetype)initAsCopyOf:(XeeArchiveEntry *)other;
- (void)dealloc;

- (NSString *)descriptiveName;
@property (readonly, retain) XeeFSRef *ref;
@property (readonly, copy) NSString *path;
@property (readonly, copy) NSString *filename;
@property (readonly) uint64_t size;
@property (readonly) double time;

- (BOOL)isEqual:(XeeArchiveEntry *)other;
- (NSUInteger)hash;

@end
