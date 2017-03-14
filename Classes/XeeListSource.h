#import "XeeImageSource.h"

@class XeeListEntry;

@interface XeeListSource:XeeImageSource
{
	NSMutableArray *entries;
	NSRecursiveLock *listlock,*loadlock;
	NSArray *types;

	XeeListEntry *currentry,*nextentry,*preventry;
	NSInteger changes,oldindex;

	BOOL loader_running,exiting;
	XeeImage *loadingimage;
}

-(instancetype)init;

-(void)stop;

@property (readonly) NSInteger numberOfImages;
@property (readonly) NSInteger indexOfCurrentImage;
-(NSString *)descriptiveNameOfCurrentImage;

-(void)pickImageAtIndex:(NSInteger)index next:(NSInteger)next;
-(void)pickImageAtIndex:(NSInteger)index;

-(void)startListUpdates;
-(void)endListUpdates;

-(void)addEntry:(XeeListEntry *)entry;
-(void)addEntryUnlessExists:(XeeListEntry *)entry;
-(void)removeEntry:(XeeListEntry *)entry;
-(void)removeEntryMatchingObject:(id)obj;
-(void)removeAllEntries;

-(void)setCurrentEntry:(XeeListEntry *)entry;
-(void)setPreviousEntry:(XeeListEntry *)entry;
-(void)setNextEntry:(XeeListEntry *)entry;

-(void)launchLoader;
-(void)loader;

@end



@interface XeeListEntry:NSObject <NSCopying>
{
	XeeImage *savedimage;
	int imageretain;
}

-(instancetype)init;
-(instancetype)initAsCopyOf:(XeeListEntry *)other;

-(NSString *)descriptiveName;
-(BOOL)matchesObject:(id)obj;

-(void)retainImage;
-(void)releaseImage;
-(XeeImage *)image;
-(XeeImage *)produceImage;

-(id)copyWithZone:(NSZone *)zone;

@end
