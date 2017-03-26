#import "XeeFileSource.h"
#import "XeeImage.h"
#import "XeeStringAdditions.h"

static NSString *findCoreAudioSoundNamed(NSString *name)
{
	// TODO: there has to be a better way...
	NSURL *caURL = [[NSFileManager defaultManager] URLForDirectory:NSLibraryDirectory inDomain:NSSystemDomainMask appropriateForURL:nil create:NO error:NULL];
	caURL = [[caURL URLByAppendingPathComponent:@"Components"] URLByAppendingPathComponent:@"CoreAudio.component"];
	NSBundle *aBund = [NSBundle bundleWithURL:caURL];
	NSURL *soundURL = aBund.sharedSupportURL;
	soundURL = [soundURL URLByAppendingPathComponent:@"SystemSounds"];
	soundURL = [soundURL URLByAppendingPathComponent:name];
	soundURL = [soundURL URLByAppendingPathExtension:@"aif"];
	return soundURL.path;
}

@implementation XeeFileSource

- (id)init
{
	if (self = [super init]) {
	}
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

- (NSString *)filenameOfCurrentImage
{
	return [(XeeFileEntry *)currentry filename];
}

- (uint64_t)sizeOfCurrentImage
{
	[(XeeFileEntry *)currentry prepareForSortingBy:XeeSizeSortOrder];
	return [(XeeFileEntry *)currentry size];
}

- (NSDate *)dateOfCurrentImage
{
	[(XeeFileEntry *)currentry prepareForSortingBy:XeeDateSortOrder];
	return [NSDate dateWithTimeIntervalSinceReferenceDate:[(XeeFileEntry *)currentry time]];
}

- (BOOL)isCurrentImageRemote
{
	XeeFSRef *ref = [(XeeFileEntry *)currentry ref];
	if (!ref)
		return NO;
	return [ref isRemote];
}

- (BOOL)isCurrentImageAtPath:(NSString *)path
{
	return [path isEqual:[(XeeFileEntry *)currentry path]];
}

- (void)setSortOrder:(XeeSortOrder)order
{
	[super setSortOrder:order];
	[self sortFiles];
}

- (void)runSorter
{
	NSEnumerator *enumerator = [entries objectEnumerator];
	XeeFileEntry *entry;
	while (entry = [enumerator nextObject])
		[entry prepareForSortingBy:sortorder];

	switch (sortorder) {
	case XeeDateSortOrder:
		[entries sortUsingSelector:@selector(compareTimes:)];
		break;
	case XeeSizeSortOrder:
		[entries sortUsingSelector:@selector(compareSizes:)];
		break;
	default:
		[entries sortUsingSelector:@selector(comparePaths:)];
		break;
	}

	[entries makeObjectsPerformSelector:@selector(finishSorting)];

	changes |= XeeSortingChange;
}

- (void)sortFiles
{
	[self startListUpdates];
	[self runSorter];
	[self endListUpdates];
}

- (BOOL)renameCurrentImageTo:(NSString *)newname error:(NSError **)error
{
	NSString *currpath = [(XeeFileEntry *)currentry path];
	NSString *newpath = [[currpath stringByDeletingLastPathComponent]
		stringByAppendingPathComponent:newname];

	if ([currpath isEqual:newpath])
		return YES;

	if ([[NSFileManager defaultManager] fileExistsAtPath:newpath]) {
		if (error) {
			*error = [NSError errorWithDomain:XeeErrorDomain
										 code:XeeFileExistsError
									 userInfo:
										 [NSDictionary dictionaryWithObjectsAndKeys:
														   NSLocalizedString(@"Couldn't rename file", @"Title of the rename error dialog"), NSLocalizedDescriptionKey,
														   [NSString stringWithFormat:NSLocalizedString(@"The file \"%@\" could not be renamed because another file with the same name already exists.", @"Content of the rename collision dialog"),
																					  [currpath lastPathComponent]],
														   NSLocalizedRecoverySuggestionErrorKey,
														   newpath, NSFilePathErrorKey,
														   nil]];
		}
		return NO;
	}

	NSError *theError;
	if (![[NSFileManager defaultManager] moveItemAtPath:currpath toPath:newpath error:&theError]) {
		if (error) {
			*error = [NSError errorWithDomain:XeeErrorDomain
										 code:XeeRenameError
									 userInfo:
										 [NSDictionary dictionaryWithObjectsAndKeys:
														   NSLocalizedString(@"Couldn't rename file", @"Title of the rename error dialog"), NSLocalizedDescriptionKey,
														   [NSString stringWithFormat:NSLocalizedString(@"The file \"%@\" could not be renamed.", @"Content of the rename error dialog"),
																					  [currpath lastPathComponent]],
														   NSLocalizedRecoverySuggestionErrorKey,
														   newpath, NSFilePathErrorKey,
														   theError, NSUnderlyingErrorKey,
														   nil]];
		}
		return NO;
	}

	// success, let kqueue update list

	return YES;
}

- (BOOL)deleteCurrentImageWithError:(NSError **)error
{
	XeeFSRef *ref = [(XeeFileEntry *)currentry ref];
	NSString *path = [ref path];
	NSURL *urlPath = ref.URL;
	BOOL res = YES;
	NSError *inErr = nil;

	if ([ref isRemote]) {
		res = [[NSFileManager defaultManager] removeItemAtURL:urlPath error:&inErr];
	} else {
		res = [[NSWorkspace sharedWorkspace]
			performFileOperation:NSWorkspaceRecycleOperation
						  source:[path stringByDeletingLastPathComponent]
					 destination:@""
						   files:[NSArray arrayWithObject:[path lastPathComponent]]
							 tag:nil];
	}

	if (!res) {
		if (error) {
			*error = [NSError errorWithDomain:XeeErrorDomain
										 code:XeeDeleteError
									 userInfo:
										 [NSDictionary dictionaryWithObjectsAndKeys:
														   NSLocalizedString(@"Couldn't delete file", @"Title of the delete failure dialog"), NSLocalizedDescriptionKey,
														   [NSString stringWithFormat:NSLocalizedString(@"The file \"%@\" could not be deleted.", @"Content of the delet failure dialog"),
																					  [path lastPathComponent]],
														   NSLocalizedRecoverySuggestionErrorKey,
														   path, NSFilePathErrorKey,
														   inErr, NSUnderlyingErrorKey,
														   nil]];
		}
		return NO;
	}

	// success, let kqueue update list
	[self playSound:findCoreAudioSoundNamed(@"dock/drag to trash")];

	return YES;
}

- (BOOL)copyCurrentImageTo:(NSString *)destination error:(NSError **)error
{
	NSString *currpath = [(XeeFileEntry *)currentry path];
	NSError *inErr = nil;

	if ([[NSFileManager defaultManager] fileExistsAtPath:destination])
		[[NSFileManager defaultManager] removeItemAtPath:destination error:NULL];

	if (![[NSFileManager defaultManager] copyItemAtPath:currpath toPath:destination error:&inErr]) {
		if (error) {
			*error = [NSError errorWithDomain:XeeErrorDomain
										 code:XeeCopyError
									 userInfo:
										 [NSDictionary dictionaryWithObjectsAndKeys:
														   NSLocalizedString(@"Couldn't copy file", @"Title of the copy failure dialog"), NSLocalizedDescriptionKey,
														   [NSString stringWithFormat:NSLocalizedString(@"The file \"%@\" could not be copied to the folder \"%@\".", @"Content of the copy failure dialog"),
																					  [currpath lastPathComponent], [destination stringByDeletingLastPathComponent]],
														   NSLocalizedRecoverySuggestionErrorKey,
														   destination, NSFilePathErrorKey,
														   inErr, NSUnderlyingErrorKey,
														   nil]];
		}
		return NO;
	}

	// "copied" message in status bar
	[self playSound:findCoreAudioSoundNamed(@"system/Volume Mount")];

	return YES;
}

- (BOOL)moveCurrentImageTo:(NSString *)destination error:(NSError **)error
{
	NSString *currpath = [(XeeFileEntry *)currentry path];
	NSError *inErr = nil;

	if ([[NSFileManager defaultManager] fileExistsAtPath:destination])
		[[NSFileManager defaultManager] removeItemAtPath:destination error:NULL];

	if (![[NSFileManager defaultManager] moveItemAtPath:currpath toPath:destination error:&inErr]) {
		if (error) {
			*error = [NSError errorWithDomain:XeeErrorDomain
										 code:XeeMoveError
									 userInfo:
										 [NSDictionary dictionaryWithObjectsAndKeys:
														   NSLocalizedString(@"Couldn't move file", @"Title of the move failure dialog"), NSLocalizedDescriptionKey,
														   [NSString stringWithFormat:NSLocalizedString(@"The file \"%@\" could not be moved to the folder \"%@\".", @"Content of the move failure dialog"),
																					  [currpath lastPathComponent], [destination stringByDeletingLastPathComponent]],
														   NSLocalizedRecoverySuggestionErrorKey,
														   destination, NSFilePathErrorKey,
														   inErr, NSUnderlyingErrorKey,
														   nil]];
		}
		return NO;
	}

	// "moved" message in status bar
	[self playSound:findCoreAudioSoundNamed(@"system/Volume Mount")];
	// success, let kqueue update list

	return YES;
}

- (BOOL)openCurrentImageWithApplication:(NSString *)app error:(NSError **)error
{
	NSString *currpath = [(XeeFileEntry *)currentry path];

	// TODO: handle errors
	//- (nullable NSRunningApplication *)openURLs:(NSArray<NSURL *> *)urls withApplicationAtURL:(NSURL *)applicationURL options:(NSWorkspaceLaunchOptions)options configuration:(NSDictionary<NSString *, id> *)configuration error:(NSError **)error NS_AVAILABLE_MAC(10_10);

	if ([NSWorkspace instancesRespondToSelector:@selector(openURLs:withApplicationAtURL:options:configuration:error:)]) {
		NSString *appPath = [[NSWorkspace sharedWorkspace] fullPathForApplication:app];
		if (!appPath) {
			if (error) {
				*error = [NSError errorWithDomain:NSCocoaErrorDomain
											 code:NSFileNoSuchFileError
										 userInfo:
											 @{ NSLocalizedFailureReasonErrorKey : [NSString stringWithFormat:NSLocalizedString(@"Unable to locate an application named \"%@\"", @"could not locate app to open document with"), app]
											 }];
			}
			return NO;
		}
		id success = [[NSWorkspace sharedWorkspace] openURLs:@[ [NSURL fileURLWithPath:currpath] ] withApplicationAtURL:[NSURL fileURLWithPath:appPath] options:(NSWorkspaceLaunchWithErrorPresentation)configuration:@{} error:error];
		if (!success) {
			return NO;
		}
	} else {
		[[NSWorkspace sharedWorkspace] openFile:currpath withApplication:app];
	}

	return YES;
}

- (NSError *)renameCurrentImageTo:(NSString *)newname
{
	NSError *outErr = nil;
	if (![self renameCurrentImageTo:newname error:&outErr]) {
		return outErr;
	}
	return nil;
}

- (NSError *)deleteCurrentImage
{
	NSError *outErr = nil;
	if (![self deleteCurrentImageWithError:&outErr]) {
		return outErr;
	}
	return nil;
}

- (NSError *)copyCurrentImageTo:(NSString *)destination
{
	NSError *outErr = nil;
	if (![self copyCurrentImageTo:destination error:&outErr]) {
		return outErr;
	}
	return nil;
}

- (NSError *)moveCurrentImageTo:(NSString *)destination
{
	NSError *outErr = nil;
	if (![self moveCurrentImageTo:destination error:&outErr]) {
		return outErr;
	}
	return nil;
}

- (NSError *)openCurrentImageInApp:(NSString *)app
{
	NSError *outErr = nil;
	if (![self openCurrentImageWithApplication:app error:&outErr]) {
		return outErr;
	}
	return nil;
}

- (void)playSound:(NSString *)filename
{
	if ([[NSUserDefaults standardUserDefaults] boolForKey:@"com.apple.sound.uiaudio.enabled"]) {
		[self performSelector:@selector(actuallyPlaySound:) withObject:filename afterDelay:0];
	}
}

- (void)actuallyPlaySound:(NSString *)filename
{
	[[[[NSSound alloc] initWithContentsOfFile:filename byReference:NO] autorelease] play];
}

@end

@implementation XeeFileEntry

- (id)init
{
	if (self = [super init]) {
		pathbuf = NULL;
	}
	return self;
}

- (void)dealloc
{
	free(pathbuf);
	[super dealloc];
}

- (XeeImage *)produceImage
{
	return [XeeImage imageForRef:[self ref]];
}

- (XeeFSRef *)ref
{
	return nil;
}

- (NSString *)path
{
	return [[self ref] path];
}

- (NSString *)filename
{
	return nil;
}

- (uint64_t)size
{
	return 0;
}

- (double)time
{
	return 0;
}

- (void)prepareForSortingBy:(XeeSortOrder)sortorder
{
	switch (sortorder) {
	case XeeDateSortOrder:
		break;

	case XeeSizeSortOrder:
		break;

	default: {
		NSString *path = [self descriptiveName];
		pathlen = [path length];
		pathbuf = malloc(pathlen * sizeof(UniChar));
		[path getCharacters:pathbuf];
	} break;
	}
}

- (void)finishSorting
{
	free(pathbuf);
	pathbuf = NULL;
}

- (NSComparisonResult)comparePaths:(XeeFileEntry *)other
{
	SInt32 res;
	UCCompareTextDefault(kUCCollateComposeInsensitiveMask | kUCCollateWidthInsensitiveMask |
							 kUCCollateCaseInsensitiveMask | kUCCollateDigitsOverrideMask | kUCCollateDigitsAsNumberMask |
							 kUCCollatePunctuationSignificantMask,
						 pathbuf, pathlen, other->pathbuf, other->pathlen, NULL, &res);
	return res;
}

- (NSComparisonResult)compareSizes:(XeeFileEntry *)other
{
	uint64_t size1 = [self size];
	uint64_t size2 = [other size];

	if (size1 == size2) {
		return NSOrderedSame;
	} else if (size1 > size2) {
		return NSOrderedAscending;
	} else {
		return NSOrderedDescending;
	}
}

- (NSComparisonResult)compareTimes:(XeeFileEntry *)other
{
	double time1 = [self time];
	double time2 = [other time];

	if (time1 == time2) {
		return NSOrderedSame;
	} else if (time1 > time2) {
		return NSOrderedAscending;
	} else {
		return NSOrderedDescending;
	}
}

- (NSString *)description
{
	return [NSString stringWithFormat:@"%@", [self path]];
}

@end
