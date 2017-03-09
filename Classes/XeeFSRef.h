#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface XeeFSRef:NSObject <NSCopying>
{
	FSRef ref;
	FSIterator iterator;
	int hash;
}

+(nullable instancetype)refForPath:(NSString *)path;

-(nullable instancetype)initWithPath:(NSString *)path;
-(instancetype)initWithFSRef:(FSRef *)fsref;

@property (readonly) FSRef *FSRef NS_RETURNS_INNER_POINTER;

@property (readonly, getter=isValid) BOOL valid;
@property (readonly, getter=isDirectory) BOOL directory;
@property (readonly, getter=isRemote) BOOL remote;

@property (readonly, nullable) NSString *name;
@property (readonly, nullable) NSString *path;
@property (readonly, nullable) NSURL *URL;
-(nullable XeeFSRef *)parent;

@property (readonly) off_t dataSize;
@property (readonly) off_t dataPhysicalSize;
@property (readonly) off_t resourceSize;
@property (readonly) off_t resourcePhysicalSize;

@property (readonly) CFAbsoluteTime creationTime;
@property (readonly) CFAbsoluteTime modificationTime;
@property (readonly) CFAbsoluteTime attributeModificationTime;
@property (readonly) CFAbsoluteTime accessTime;
@property (readonly) CFAbsoluteTime backupTime;

@property (readonly) NSString *HFSTypeCode;
@property (readonly) NSString *HFSCreatorCode;

-(BOOL)startReadingDirectoryWithRecursion:(BOOL)recursive;
-(void)stopReadingDirectory;
-(nullable XeeFSRef *)nextDirectoryEntry;
-(NSArray<XeeFSRef*> *)directoryContents;

-(NSComparisonResult)compare:(XeeFSRef *)other;
-(NSComparisonResult)compare:(XeeFSRef *)other options:(NSStringCompareOptions)options;
//-(NSUInteger)hash;

//-(NSString *)description;

@end

NS_ASSUME_NONNULL_END
