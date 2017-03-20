#import "XeeFSRef.h"

@implementation XeeFSRef

+(XeeFSRef *)refForPath:(NSString *)path
{
	return [[XeeFSRef alloc] initWithPath:path];
}

-(id)initWithPath:(NSString *)path
{
	FSRef tmpRef;
	if (FSPathMakeRef((const UInt8 *)[path fileSystemRepresentation], &tmpRef, NULL) != noErr) {
		[self release];
		return nil;
	}
	
	return [self initWithFSRef:&tmpRef];
}

-(id)initWithFSRef:(FSRef *)fsref
{
	if (self = [super init]) {
		ref=*fsref;
		iterator=NULL;

		FSCatalogInfo catinfo;
		FSGetCatalogInfo(&ref,kFSCatInfoNodeID,&catinfo,NULL,NULL,NULL)/*!=noErr*/;
		hash=catinfo.nodeID;
	}
	return self;
}

-(void)dealloc
{
	if(iterator) {
		FSCloseIterator(iterator);
	}
}

-(FSRef *)FSRef
{
	return &ref;
}

-(BOOL)isValid
{
	return FSIsFSRefValid(&ref);
}

-(BOOL)isDirectory
{
	FSCatalogInfo catinfo;
	if (FSGetCatalogInfo(&ref, kFSCatInfoNodeFlags, &catinfo, NULL, NULL, NULL) != noErr) {
		return NO;
	}
	return (catinfo.nodeFlags & kFSNodeIsDirectoryMask) ? YES : NO;
}

-(BOOL)isRemote
{
	NSURL *currentURL = CFBridgingRelease(CFURLCreateFromFSRef(kCFAllocatorDefault, &ref));
	NSNumber *aNum = nil;
	
	BOOL success = [currentURL getResourceValue:&aNum forKey:NSURLVolumeIsLocalKey error:NULL];
	if (!success) {
		return NO;
	}
	return ![aNum boolValue];
}


-(NSString *)name;
{
	HFSUniStr255 name;
	if (FSGetCatalogInfo(&ref, kFSCatInfoNone, NULL, &name, NULL, NULL) != noErr) {
		return nil;
	}
	return [NSString stringWithCharacters:name.unicode length:MIN(name.length, 255)];
}

-(NSString *)path
{
	return self.URL.path;
}

- (const char*)fileSystemRepresentation
{
	if ([NSURL instancesRespondToSelector:@selector(fileSystemRepresentation)]) {
		return self.URL.fileSystemRepresentation;
	} else {
		return self.path.fileSystemRepresentation;
	}
}

-(NSURL *)URL
{
	return CFBridgingRelease(CFURLCreateFromFSRef(kCFAllocatorDefault, &ref));
}

-(XeeFSRef *)parent
{
	FSRef parent;
	if (FSGetCatalogInfo(&ref, kFSCatInfoNone, NULL, NULL, NULL, &parent) != noErr)
		return nil;
	return [[XeeFSRef alloc] initWithFSRef:&parent];
}



-(off_t)dataSize
{
	FSCatalogInfo catinfo;
	if (FSGetCatalogInfo(&ref, kFSCatInfoDataSizes, &catinfo, NULL, NULL, NULL) != noErr)
		return 0;
	return catinfo.dataLogicalSize;
}

-(off_t)dataPhysicalSize
{
	FSCatalogInfo catinfo;
	if (FSGetCatalogInfo(&ref, kFSCatInfoDataSizes, &catinfo, NULL, NULL, NULL) != noErr)
		return 0;
	return catinfo.dataPhysicalSize;
}

-(off_t)resourceSize
{
	FSCatalogInfo catinfo;
	if (FSGetCatalogInfo(&ref, kFSCatInfoDataSizes, &catinfo, NULL, NULL, NULL) != noErr)
		return 0;
	return catinfo.rsrcLogicalSize;
}

-(off_t)resourcePhysicalSize
{
	FSCatalogInfo catinfo;
	if(FSGetCatalogInfo(&ref,kFSCatInfoDataSizes,&catinfo,NULL,NULL,NULL) != noErr)
		return 0;
	return catinfo.rsrcPhysicalSize;
}



-(CFAbsoluteTime)creationTime
{
	FSCatalogInfo catinfo;
	if (FSGetCatalogInfo(&ref, kFSCatInfoCreateDate, &catinfo, NULL, NULL, NULL) != noErr)
		return 0;
	CFAbsoluteTime res;
	UCConvertUTCDateTimeToCFAbsoluteTime(&catinfo.createDate, &res);
	return res;
}

-(CFAbsoluteTime)modificationTime
{
	FSCatalogInfo catinfo;
	if (FSGetCatalogInfo(&ref, kFSCatInfoAllDates, &catinfo, NULL, NULL, NULL) != noErr)
		return 0;
	CFAbsoluteTime res;
	UCConvertUTCDateTimeToCFAbsoluteTime(&catinfo.contentModDate, &res);
	return res;
}

-(CFAbsoluteTime)attributeModificationTime
{
	FSCatalogInfo catinfo;
	if (FSGetCatalogInfo(&ref, kFSCatInfoAllDates, &catinfo, NULL, NULL, NULL) != noErr)
		return 0;
	CFAbsoluteTime res;
	UCConvertUTCDateTimeToCFAbsoluteTime(&catinfo.attributeModDate, &res);
	return res;
}

-(CFAbsoluteTime)accessTime
{
	FSCatalogInfo catinfo;
	if (FSGetCatalogInfo(&ref, kFSCatInfoAccessDate, &catinfo, NULL, NULL, NULL) != noErr) {
		return 0;
	}
	CFAbsoluteTime res;
	UCConvertUTCDateTimeToCFAbsoluteTime(&catinfo.accessDate,&res);
	return res;
}

-(CFAbsoluteTime)backupTime
{
	FSCatalogInfo catinfo;
	if (FSGetCatalogInfo(&ref, kFSCatInfoBackupDate, &catinfo, NULL, NULL, NULL) != noErr) {
		return 0;
	}
	CFAbsoluteTime res;
	UCConvertUTCDateTimeToCFAbsoluteTime(&catinfo.backupDate,&res);
	return res;
}


-(NSString *)HFSTypeCode
{
	FSCatalogInfo catinfo;
	if (FSGetCatalogInfo(&ref, kFSCatInfoFinderInfo, &catinfo, NULL, NULL, NULL) != noErr)
		return nil;
	struct FileInfo *info=(struct FileInfo *)&catinfo.finderInfo;
	OSType type=info->fileType;
	return CFBridgingRelease(UTCreateStringForOSType(type));
}

-(NSString *)HFSCreatorCode
{
	FSCatalogInfo catinfo;
	if (FSGetCatalogInfo(&ref, kFSCatInfoFinderInfo, &catinfo, NULL, NULL, NULL) != noErr)
		return nil;
	struct FileInfo *info=(struct FileInfo *)&catinfo.finderInfo;
	OSType type=info->fileType;
	return CFBridgingRelease(UTCreateStringForOSType(type));
}


-(BOOL)startReadingDirectoryWithRecursion:(BOOL)recursive
{
	return [self startReadingDirectoryWithRecursion:recursive error:NULL];
}

-(BOOL)startReadingDirectoryWithRecursion:(BOOL)recursive error:(NSError**)error
{
	if (iterator)
		FSCloseIterator(iterator);
	// "Iteration over subtrees which do not originate at the root directory of a volume are not currently supported"
	OSErr err = FSOpenIterator(&ref, recursive ? kFSIterateSubtree : kFSIterateFlat, &iterator);
	if (err == noErr) {
		return YES;
	}
	if (error) {
		*error = [NSError errorWithDomain:NSOSStatusErrorDomain code:err userInfo:nil];
	}
	return NO;
}

-(void)stopReadingDirectory
{
	if (iterator) {
		FSCloseIterator(iterator);
	}
	iterator=NULL;
}

-(XeeFSRef *)nextDirectoryEntry
{
	if (!iterator)
		return nil;

	FSRef newref;
	ItemCount num;
	OSErr err = FSGetCatalogInfoBulk(iterator, 1, &num, NULL, kFSCatInfoNone, NULL, &newref, NULL, NULL);
	// ignoring num

	if (err == errFSNoMoreItems) {
		FSCloseIterator(iterator);
		iterator=NULL;
		return nil;
	} else if (err != noErr) {
		return nil;
	}

	return [[XeeFSRef alloc] initWithFSRef:&newref];
}

-(NSArray *)directoryContents
{
	if(![self startReadingDirectoryWithRecursion:NO])
		return nil;

	NSMutableArray *array = [NSMutableArray array];
	XeeFSRef *entry;
	while((entry = [self nextDirectoryEntry])) {
		[array addObject:entry];
	}

	return [array copy];
}

-(BOOL)isEqual:(XeeFSRef *)other
{
	if (![other isKindOfClass:[XeeFSRef class]])
		return NO;
	//if(![self isValid]||![other isValid]) return NO; // This is REALLY SLOW for some reason.
	if (hash != other->hash)
		return NO;
	return FSCompareFSRefs(&ref, &other->ref) == noErr;
}

-(NSComparisonResult)compare:(XeeFSRef *)other
{
	return [[self path] compare:[other path] options:NSCaseInsensitiveSearch|NSNumericSearch];
}

-(NSComparisonResult)compare:(XeeFSRef *)other options:(NSStringCompareOptions)options
{
	return [[self path] compare:[other path] options:options];
}

-(NSUInteger)hash
{
	return hash;
}

-(NSString *)description
{
	return [self path];
}

-(id)copyWithZone:(NSZone *)zone
{
	return [[XeeFSRef alloc] initWithFSRef:&ref];
}

@end
