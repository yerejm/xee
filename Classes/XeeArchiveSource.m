#import "XeeArchiveSource.h"
#import "XeeImage.h"

#import <unistd.h>

@implementation XeeArchiveSource

+ (NSArray *)fileTypes
{
	static NSArray *types;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		NSMutableArray *toAdd = [NSMutableArray arrayWithCapacity:20];
		[toAdd addObjectsFromArray:
				   @[ @"zip", @"cbz", @"rar", @"cbr", @"7z", @"cb7", @"lha", @"lzh",
					  @"000", @"001", @"iso", @"bin", @"alz", @"sit", @"sitx" ]];

		// File types from HFS codes:
		[toAdd addObject:NSFileTypeForHFSTypeCode('SIT!')];
		[toAdd addObject:NSFileTypeForHFSTypeCode('SITD')];
		[toAdd addObject:NSFileTypeForHFSTypeCode('SIT5')];

		[toAdd addObject:(NSString *)kUTTypeGNUZipArchive];
		[toAdd addObject:(NSString *)kUTTypeBzip2Archive];
		[toAdd addObject:(NSString *)kUTTypeZipArchive];

		// other UTIs
		[toAdd addObject:@"org.7-zip.7-zip-archive"];
		[toAdd addObject:@"com.allume.stuffit-archive"];
		[toAdd addObject:@"com.stuffit.archive.sitx"];
		[toAdd addObject:@"public.iso-image"];
		[toAdd addObject:@"cx.c3.lha-archive"];
		[toAdd addObject:@"com.rarlab.rar-archive"];

		types = [toAdd copy];
	});

	return types;
}

- (id)initWithArchive:(NSString *)archivename
{
	if (self = [super init]) {
		filename = [archivename copy];

		parser = nil;
		tmpdir = [NSTemporaryDirectory() stringByAppendingPathComponent:
											  [NSString stringWithFormat:@"Xee-archive-%04lx%04lx%04lx", random() & 0xffff, random() & 0xffff, random() & 0xffff]];

		[[NSFileManager defaultManager] createDirectoryAtPath:tmpdir withIntermediateDirectories:NO attributes:nil error:nil];

		[self setIcon:[[NSWorkspace sharedWorkspace] iconForFile:archivename]];
		[icon setSize:NSMakeSize(16, 16)];

		@try {
			parser = [XADArchiveParser archiveParserForPath:archivename];
		}
		@catch (id e) {
		}

		if (!parser)
			return nil;
	}

	return self;
}

- (void)dealloc
{
	[[NSFileManager defaultManager] removeItemAtPath:tmpdir error:NULL];
}

- (void)start
{
	[self startListUpdates];

	@try {
		n = 0;
		[parser setDelegate:self];
		[parser parse];
	}
	@catch (id e) {
		NSLog(@"Error parsing archive file %@: %@", filename, e);
	}

	[self runSorter];

	[self endListUpdates];
	[self pickImageAtIndex:0];

	parser = nil;
}

- (void)archiveParser:(XADArchiveParser *)dummy foundEntryWithDictionary:(NSDictionary *)dict
{
	NSNumber *isdir = [dict objectForKey:XADIsDirectoryKey];
	NSNumber *islink = [dict objectForKey:XADIsLinkKey];

	if (isdir && [isdir boolValue])
		return;
	if (islink && [islink boolValue])
		return;

	NSString *name = [[dict objectForKey:XADFileNameKey] string];
	NSString *ext = [[name pathExtension] lowercaseString];
	NSNumber *typenum = [dict objectForKey:XADFileTypeKey];
	uint32_t typeval = typenum ? [typenum unsignedIntValue] : 0;
	NSString *type = NSFileTypeForHFSTypeCode(typeval);

	NSArray *filetypes = [XeeImage allFileTypes];

	if ([filetypes indexOfObject:ext] != NSNotFound || [filetypes indexOfObject:type] != NSNotFound) {
		NSString *realpath = [tmpdir stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", n++]];
		[self addEntry:[[XeeArchiveEntry alloc]
						   initWithArchiveParser:parser
										   entry:dict
										realPath:realpath]];
	}
}

- (void)archiveParserNeedsPassword:(XADArchiveParser *)dummy
{
	[parser setPassword:[self demandPassword]];
}

- (NSString *)windowTitle
{
	return [NSString stringWithFormat:@"%@ (%@)", [filename lastPathComponent], [currentry descriptiveName]];
}

- (NSString *)windowRepresentedFilename
{
	return filename;
}

- (BOOL)canBrowse
{
	return currentry != nil;
}

- (BOOL)canSort
{
	return currentry != nil;
}

- (BOOL)canCopyCurrentImage
{
	return currentry != nil;
}

@end

@implementation XeeArchiveEntry
@synthesize path;
@synthesize size;
@synthesize time;

- (id)initWithArchiveParser:(XADArchiveParser *)parent entry:(NSDictionary *)entry realPath:(NSString *)realpath
{
	if (self = [super init]) {
		parser = parent;
		dict = [entry copy];
		path = [realpath copy];
		ref = nil;

		size = [[dict objectForKey:XADFileSizeKey] unsignedLongLongValue];

		NSDate *date = [dict objectForKey:XADLastModificationDateKey];
		if (date)
			time = [date timeIntervalSinceReferenceDate];
		else
			date = 0;
	}
	return self;
}

- (id)initAsCopyOf:(XeeArchiveEntry *)other
{
	if (self = [super initAsCopyOf:other]) {
		parser = other->parser;
		dict = [other->dict copy];
		ref = other->ref;
		path = [other->path copy];
		size = other->size;
		time = other->time;
	}
	return self;
}

- (NSString *)descriptiveName
{
	return [[dict objectForKey:XADFileNameKey] string];
}

- (XeeFSRef *)ref
{
	if (!ref) {
		int fh = open([path fileSystemRepresentation], O_WRONLY | O_CREAT | O_TRUNC, 0666);
		if (fh == -1)
			return nil;

		@try {
			CSHandle *srchandle = [parser handleForEntryWithDictionary:dict wantChecksum:NO];
			if (!srchandle)
				@throw @"Failed to get handle";

			uint8_t buf[65536];
			for (;;) {
				int actual = [srchandle readAtMost:sizeof(buf) toBuffer:buf];
				if (actual == 0)
					break;
				if (write(fh, buf, actual) != actual)
					@throw @"Failed to write to file";
			}
		}
		@catch (id e) {
			NSLog(@"Error extracting file %@ from archive %@.", [self descriptiveName], [parser filename]);
			close(fh);
			return nil;
		}

		close(fh);

		ref = [[XeeFSRef alloc] initWithPath:path];
	}
	return ref;
}

- (NSString *)filename
{
	//return [[NSFileManager defaultManager] displayNameAtPath:[[dict objectForKey:XADFileNameKey] string]];
	return [[[dict objectForKey:XADFileNameKey] string] lastPathComponent];
}

- (BOOL)isEqual:(XeeArchiveEntry *)other
{
	if (![other isKindOfClass:[XeeArchiveEntry class]]) {
		return NO;
	}
	return parser == other->parser && dict == other->dict;
}

- (NSUInteger)hash
{
	return (uintptr_t)parser ^ (uintptr_t)dict;
}

@end
