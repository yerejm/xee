#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

DEPRECATED_ATTRIBUTE
@interface XeeFSRef : NSObject <NSCopying> {
	FSRef ref;
	FSIterator iterator;
	int hash;
}

+ (nullable instancetype)refForPath:(NSString *)path NS_SWIFT_UNAVAILABLE("Use `init(path:)` instead");
+ (nullable instancetype)refWithFileURL:(NSURL *)path;

- (nullable instancetype)initWithPath:(NSString *)path;
- (nullable instancetype)initWithFileURL:(NSURL *)path;
- (instancetype)initWithFSRef:(FSRef *)fsref NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@property (readonly) FSRef *FSRef NS_RETURNS_INNER_POINTER;

@property (readonly, getter=isValid) BOOL valid;
@property (readonly, getter=isDirectory) BOOL directory;
@property (readonly, getter=isRemote) BOOL remote;

@property (readonly, nullable) NSString *name;
@property (readonly, nullable) NSString *path;
@property (readonly, nullable) NSURL *URL;
@property (readonly, nullable) const char *fileSystemRepresentation NS_RETURNS_INNER_POINTER;
- (nullable XeeFSRef *)parent;

@property (readonly) off_t dataSize;
@property (readonly) off_t dataPhysicalSize;
@property (readonly) off_t resourceSize;
@property (readonly) off_t resourcePhysicalSize;

@property (readonly) CFAbsoluteTime creationTime;
@property (readonly) CFAbsoluteTime modificationTime;
@property (readonly) CFAbsoluteTime attributeModificationTime;
@property (readonly) CFAbsoluteTime accessTime;
@property (readonly) CFAbsoluteTime backupTime;

@property (readonly, nullable) NSString *HFSTypeCode;
@property (readonly, nullable) NSString *HFSCreatorCode;

- (BOOL)startReadingDirectoryWithRecursion:(BOOL)recursive NS_SWIFT_UNAVAILABLE("Use the throwing version instead");
- (BOOL)startReadingDirectoryWithRecursion:(BOOL)recursive error:(NSError **)error;
- (void)stopReadingDirectory;
- (nullable XeeFSRef *)nextDirectoryEntry;
- (nullable NSArray<XeeFSRef *> *)directoryContents;

- (NSComparisonResult)compare:(XeeFSRef *)other;
- (NSComparisonResult)compare:(XeeFSRef *)other options:(NSStringCompareOptions)options;
//-(NSUInteger)hash;

//-(NSString *)description;

@end

NS_ASSUME_NONNULL_END
