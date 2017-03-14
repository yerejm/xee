#import "XeeListSource.h"
#import "XeeFSRef.h"

@class XeeFileEntry;

@interface XeeFileSource:XeeListSource
{
}

-(id)init;

@property (readonly) uint64_t sizeOfCurrentImage;
@property (readonly) NSDate * dateOfCurrentImage;
@property (readonly, getter=isCurrentImageRemote) BOOL currentImageRemote;
-(BOOL)isCurrentImageAtPath:(NSString *)path;

-(void)setSortOrder:(XeeSortOrder)order;

-(void)runSorter;
-(void)sortFiles;

-(NSError *)renameCurrentImageTo:(NSString *)newname DEPRECATED_ATTRIBUTE;
-(NSError *)deleteCurrentImage DEPRECATED_ATTRIBUTE;
-(NSError *)copyCurrentImageTo:(NSString *)destination NS_RETURNS_NOT_RETAINED DEPRECATED_ATTRIBUTE;
-(NSError *)moveCurrentImageTo:(NSString *)destination DEPRECATED_ATTRIBUTE;
-(NSError *)openCurrentImageInApp:(NSString *)app DEPRECATED_ATTRIBUTE;

-(BOOL)renameCurrentImageTo:(NSString *)newname error:(NSError**)error;
-(BOOL)deleteCurrentImageWithError:(NSError**)error;
-(BOOL)copyCurrentImageTo:(NSString *)destination error:(NSError**)error;
-(BOOL)moveCurrentImageTo:(NSString *)destination error:(NSError**)error;
-(BOOL)openCurrentImageWithApplication:(NSString *)app error:(NSError**)error;

-(void)playSound:(NSString *)filename;
-(void)actuallyPlaySound:(NSString *)filename;

@end

@interface XeeFileEntry:XeeListEntry
{
	UniChar *pathbuf;
	int pathlen;
}

-(id)init;

-(XeeImage *)produceImage;

-(XeeFSRef *)ref;
-(NSString *)path;
-(NSString *)filename;
-(uint64_t)size;
-(double)time;

-(void)prepareForSortingBy:(XeeSortOrder)sortorder;
-(void)finishSorting;
-(NSComparisonResult)comparePaths:(XeeFileEntry *)other;
-(NSComparisonResult)compareSizes:(XeeFileEntry *)other;
-(NSComparisonResult)compareTimes:(XeeFileEntry *)other;

@end
