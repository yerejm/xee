#import "XeeFileSource.h"
#import "XeeKQueue.h"

@class XeeDirectoryEntry;

@interface XeeDirectorySource : XeeFileSource {
	XeeFSRef *dirref, *imgref;
	int dirfd, filefd;
	BOOL scheduledimagerename, scheduledimagerefresh, scheduleddirrefresh;
	XeeDirectoryEntry *first;
}

- (instancetype)initWithDirectory:(XeeFSRef *)directory;
- (instancetype)initWithRef:(XeeFSRef *)ref DEPRECATED_ATTRIBUTE;
- (instancetype)initWithFileURL:(NSURL *)ref;
- (instancetype)initWithImage:(XeeImage *)image;
- (instancetype)initWithRef:(XeeFSRef *)ref image:(XeeImage *)image DEPRECATED_ATTRIBUTE;
- (instancetype)initWithFileURL:(NSURL *)ref image:(XeeImage *)image;

- (NSString *)windowTitle;
- (NSString *)windowRepresentedFilename;

- (BOOL)canBrowse;
- (BOOL)canSort;
- (BOOL)canRenameCurrentImage;
- (BOOL)canDeleteCurrentImage;
- (BOOL)canCopyCurrentImage;
- (BOOL)canMoveCurrentImage;
- (BOOL)canOpenCurrentImage;
- (BOOL)canSaveCurrentImage;

- (NSError *)renameCurrentImageTo:(NSString *)newname DEPRECATED_ATTRIBUTE;
- (NSError *)deleteCurrentImage DEPRECATED_ATTRIBUTE;
- (NSError *)moveCurrentImageTo:(NSString *)destination DEPRECATED_ATTRIBUTE;

- (BOOL)renameCurrentImageTo:(NSString *)newname error:(NSError **)error;
- (BOOL)deleteCurrentImageWithError:(NSError **)error;
- (BOOL)moveCurrentImageTo:(NSString *)destination error:(NSError **)error;

- (void)beginSavingImage:(XeeImage *)image;
- (void)endSavingImage:(XeeImage *)image;

- (void)setCurrentEntry:(XeeFileEntry *)entry;

- (void)fileChanged:(XeeKEvent *)event;
- (void)directoryChanged:(XeeKEvent *)event;

- (void)scheduleImageRename;
- (void)scheduleImageRefresh;
- (void)scheduleDirectoryRefresh;
- (void)performScheduledTasks;

- (void)removeCurrentEntryAndUpdate;
- (void)removeAllEntriesAndUpdate;

- (void)scanDirectory;
- (void)readDirectory;

@end

@interface XeeDirectoryEntry : XeeFileEntry {
	NSURL *fileURL;
	uint64_t size;
	NSTimeInterval time;
}

+ (XeeDirectoryEntry *)entryWithRef:(XeeFSRef *)ref DEPRECATED_ATTRIBUTE;
+ (XeeDirectoryEntry *)entryWithRef:(XeeFSRef *)ref image:(XeeImage *)image DEPRECATED_ATTRIBUTE;
+ (XeeDirectoryEntry *)entryWithFileURL:(NSURL *)ref;
+ (XeeDirectoryEntry *)entryWithFileURL:(NSURL *)ref image:(XeeImage *)image;

- (id)initWithRef:(XeeFSRef *)fsref DEPRECATED_ATTRIBUTE;
- (id)initWithRef:(XeeFSRef *)fsref image:(XeeImage *)image DEPRECATED_ATTRIBUTE;
- (instancetype)initWithFileURL:(NSURL *)fsref;
- (instancetype)initWithFileURL:(NSURL *)fsref image:(XeeImage *)image;
- (instancetype)initAsCopyOf:(XeeDirectoryEntry *)other;
- (void)dealloc;

- (void)prepareForSortingBy:(XeeSortOrder)sortorder;

@property (readonly, copy) NSString *descriptiveName;
@property (readonly, retain) XeeFSRef *ref DEPRECATED_ATTRIBUTE;
@property (readonly, retain) NSURL *fileURL;
@property (readonly, copy) NSString *path;
@property (readonly, copy) NSString *filename;
@property (readonly) uint64_t size;
@property (readonly) NSTimeInterval time;

- (BOOL)matchesObject:(id)obj;

@end
