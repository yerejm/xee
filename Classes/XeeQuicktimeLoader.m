#import "XeeQuicktimeLoader.h"

#import "XeeBitmapImage.h"


//#define USE_CGIMAGE
#if __i386__

static void XeeSetQTDepth(XeeImage *image,int qtdepth);
static OSErr XeeQTProgressFunc(short message,Fixed completeness,long refcon);

// BEGIN old QuickTime definitions
typedef OSType                          CodecType;
typedef UInt16                          CodecFlags;
typedef UInt32                          CodecQ;

#pragma pack(push, 2)

struct ImageDescription {
	SInt32              idSize;                 /* total size of ImageDescription including extra data ( CLUTs and other per sequence data ) */
	CodecType           cType;                  /* what kind of codec compressed this data */
	SInt32              resvd1;                 /* reserved for Apple use */
	SInt16              resvd2;                 /* reserved for Apple use */
	SInt16              dataRefIndex;           /* set to zero  */
	SInt16              version;                /* which version is this data */
	SInt16              revisionLevel;          /* what version of that codec did this */
	SInt32              vendor;                 /* whose  codec compressed this data */
	CodecQ              temporalQuality;        /* what was the temporal quality factor  */
	CodecQ              spatialQuality;         /* what was the spatial quality factor */
	SInt16              width;                  /* how many pixels wide is this data */
	SInt16              height;                 /* how many pixels high is this data */
	Fixed               hRes;                   /* horizontal resolution */
	Fixed               vRes;                   /* vertical resolution */
	SInt32              dataSize;               /* if known, the size of data for this image descriptor */
	SInt16              frameCount;             /* number of frames this description applies to */
	Str31               name;                   /* name of codec ( in case not installed )  */
	SInt16              depth;                  /* what depth is this data (1-32) or ( 33-40 grayscale ) */
	SInt16              clutID;                 /* clut id or if 0 clut follows  or -1 if no clut */
};
typedef struct ImageDescription         ImageDescription;
typedef ImageDescription *              ImageDescriptionPtr;
typedef ImageDescriptionPtr *           ImageDescriptionHandle;
typedef ComponentInstance               GraphicsImportComponent;

typedef ComponentInstance               GraphicsExportComponent;
enum {
	GraphicsExporterComponentType = 'grex',
	kBaseGraphicsExporterSubType  = 'base'
};

enum {
	codecLosslessQuality          = 0x00000400,
	codecMaxQuality               = 0x000003FF,
	codecMinQuality               = 0x00000000,
	codecLowQuality               = 0x00000100,
	codecNormalQuality            = 0x00000200,
	codecHighQuality              = 0x00000300
};


typedef CALLBACK_API( OSErr , ICMProgressProcPtr )(short message, Fixed completeness, long refcon);
typedef STACK_UPP_TYPE(ICMProgressProcPtr) ICMProgressUPP;


struct ICMProgressProcRecord {
	ICMProgressUPP      progressProc;
	long                progressRefCon;
};
typedef struct ICMProgressProcRecord    ICMProgressProcRecord;
typedef ICMProgressProcRecord *         ICMProgressProcRecordPtr;


#pragma pack(pop)

extern OSErr GetGraphicsImporterForFile(const FSSpec *, ComponentInstance *) AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_9;
extern ComponentResult GraphicsImportGetImageDescription(GraphicsImportComponent, ImageDescriptionHandle *) AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_9;
extern ComponentResult GraphicsImportGetImageCount(GraphicsImportComponent, unsigned long*) AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_9;
extern ComponentResult GraphicsImportSetImageIndexToThumbnail(GraphicsImportComponent ci) AVAILABLE_MAC_OS_X_VERSION_10_2_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_9;
extern ComponentResult GraphicsImportSetImageIndex(GraphicsImportComponent, unsigned long) AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_9;
extern ComponentResult GraphicsExportSetProgressProc(GraphicsExportComponent, ICMProgressProcRecordPtr) AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_9;
extern ComponentResult GraphicsImportSetProgressProc(GraphicsImportComponent, ICMProgressProcRecordPtr) AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_9;
extern ComponentResult GraphicsImportSetQuality(GraphicsImportComponent, CodecQ) AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_9;
extern OSErr QTNewGWorldFromPtr(GWorldPtr *, OSType, const Rect *, CTabHandle, GDHandle, GWorldFlags, void *, long) AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_9;
extern ComponentResult GraphicsImportSetGWorld(GraphicsImportComponent, CGrafPtr, GDHandle) AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_9;
extern ComponentResult GraphicsImportDraw(GraphicsImportComponent) AVAILABLE_MAC_OS_X_VERSION_10_0_AND_LATER_BUT_DEPRECATED_IN_MAC_OS_X_VERSION_10_9;
extern OSErr EnterMovies(void);
extern OSErr EnterMoviesOnThread(UInt32 inFlags);
extern OSErr ExitMoviesOnThread(void);

// END old QuickTime definitions


@implementation XeeQuicktimeImage
@synthesize currentHeight = current_height;

+(BOOL)canOpenFile:(NSString *)filename firstBlock:(NSData *)block attributes:(NSDictionary *)attrs;
{
	if(
		[[filename pathExtension] caseInsensitiveCompare:@"bmp"]==NSOrderedSame
		||[attrs fileHFSTypeCode]=='BMP '||[attrs fileHFSTypeCode]=='BMP '
		||[[filename pathExtension] caseInsensitiveCompare:@"tga"]==NSOrderedSame
		||[attrs fileHFSTypeCode]=='TPIC'
		||[[filename pathExtension] caseInsensitiveCompare:@"sgi"]==NSOrderedSame
		||[[filename pathExtension] caseInsensitiveCompare:@"rgb"]==NSOrderedSame
		||[attrs fileHFSTypeCode]=='.SGI'
		||[[filename pathExtension] caseInsensitiveCompare:@"nef"]==NSOrderedSame
	) return NO;// explicitly exclude BMP, TGA and SGI - what the hell, Quicktime?

	return YES;
}

-(SEL)initLoader
{
	gi=NULL;

	NSURL *url=[NSURL fileURLWithPath:[self filename]];

	FSRef fsref;
	if(!CFURLGetFSRef((CFURLRef)url, &fsref))
		return NULL;

	FSSpec fsspec;
	if (FSGetCatalogInfo(&fsref, kFSCatInfoNone,NULL,NULL,&fsspec,NULL)!=noErr)
		return NULL;

	if(GetGraphicsImporterForFile(&fsspec,&gi)!=noErr) return NULL;

	ImageDescriptionHandle desc;
	if(GraphicsImportGetImageDescription(gi,&desc)!=noErr) return NULL;

	width=(*desc)->width;
	height=(*desc)->height;

	[self setFormat:[[[NSString alloc] initWithBytes:(*desc)->name+1 length:(*desc)->name[0]
	encoding:CFStringConvertEncodingToNSStringEncoding(CFStringGetSystemEncoding())] autorelease]];

	int qtdepth=(*desc)->depth;
	XeeSetQTDepth(self,qtdepth);

	DisposeHandle((Handle)desc);

	current_image = -1;

	return @selector(loadNextImage);
}

-(void)deallocLoader
{
	if (gi) {
		CloseComponent(gi);
	}
}


-(SEL)loadNextImage
{
	unsigned long count;
	GraphicsImportGetImageCount(gi,&count);

	current_image++;

	if (thumbonly) {
		if (current_image == 0) {
			if (GraphicsImportSetImageIndexToThumbnail(gi) != noErr)
				if (GraphicsImportSetImageIndex(gi,1) != noErr)
					return NULL;
		} else {
			loaded=YES;
			return NULL;
		}
	} else {
		if (current_image == count) {
			loaded=YES;
			return NULL;
		} else {
			if (GraphicsImportSetImageIndex(gi,current_image+1)!=noErr) {
				return @selector(loadNextImage);
			}
		}
	}
	return @selector(loadImage);
}

-(SEL)loadImage
{
	EnterMoviesOnThread(0);

	struct ICMProgressProcRecord progrec={XeeQTProgressFunc,(long)self};
	GraphicsImportSetProgressProc(gi,&progrec);

	GraphicsImportSetQuality(gi,codecLosslessQuality);

	ImageDescriptionHandle desc;
	if (GraphicsImportGetImageDescription(gi, &desc) != noErr)
		return @selector(loadNextImage);

	int framewidth=(*desc)->width;
	int frameheight=(*desc)->height;
	int framedepth=(*desc)->depth;
	current_height=frameheight;

	DisposeHandle((Handle)desc);

	#ifdef USE_CGIMAGE
	// 10.4 code using CGImages. QT seems buggy and gets the size of the CGImage wrong.

	CGImageRef cgimage;
	if(GraphicsImportCreateCGImage(gi,&cgimage,kGraphicsImportCreateCGImageUsingCurrentSettings)!=noErr) return @selector(loadNextImage);

	XeeBitmapImage *image;
	if(framedepth>32&&framedepth!=40) image=[[[XeeBitmapImage alloc] initWithConvertedCGImage:cgimage type:XeeBitmapTypeLuma8] autorelease];
	else image=[[[XeeBitmapImage alloc] initWithCGImage:cgimage] autorelease];
	if(!image) return @selector(loadNextImage);

	XeeSetQTDepth(image,framedepth);

	[self addSubImage:image];
	[image setCompleted];

	CGImageRelease(cgimage);

	#else

	int type;
	OSType pixelformat;

	if (framedepth > 32) {
		type=XeeBitmapTypeLuma8;
		pixelformat=k8IndexedGrayPixelFormat;
	}
	//else if([format isEqual:@"JPEG"]&&[[NSUserDefaults standardUserDefaults] integerForKey:@"jpegYUV"]==1)
	//{
	//	type=XeeBitmapTypeYUV422;
	//	pixelformat=k2vuyPixelFormat;
	//}
	else if(framedepth == 32 || framedepth == 16)
	{
		pixelformat=k32ARGBPixelFormat;
		type=XeeBitmapTypeARGB8;
	}
	else
	{
		type=XeeBitmapTypeRGB8;
		pixelformat=k24RGBPixelFormat;
	}

	XeeBitmapImage *image=[[[XeeBitmapImage alloc] initWithType:type width:framewidth height:frameheight] autorelease];
	if(!image) return @selector(loadNextImage);

	XeeSetQTDepth(image,framedepth);

	GWorldPtr gw;
	Rect rect;
	void SetRect(Rect *, int, int, int, int);
	SetRect(&rect,0,0,framewidth,frameheight);
	if (QTNewGWorldFromPtr(&gw,pixelformat,&rect,NULL,NULL,0,[image data],[image bytesPerRow])!=noErr) {
		return @selector(loadNextImage);
	}

	if (GraphicsImportSetGWorld(gi, gw, NULL) == noErr) {
//		[self addSubImage:image];

		if (GraphicsImportDraw(gi) == noErr) {
			//if(type==XeeBitmapTypeYUV422) [image fixYUVGamma];
			if (type == XeeBitmapTypeLuma8) {
				unsigned long *ptr=(unsigned long *)[image data];
				int n=[image bytesPerRow]*frameheight/4;
				while(n--) {
					*ptr=~*ptr;
					ptr++;
				}
			}

			[self addSubImage:image];
			[image setCompleted];
		}
	}
	
	void DisposeGWorld(GWorldPtr);
	DisposeGWorld(gw);
	#endif

	ExitMoviesOnThread();

	return @selector(loadNextImage);
}

-(XeeBitmapImage *)currentImage { return [subimages objectAtIndex:[subimages count]-1]; }

+(void)load
{
	EnterMovies();
}

+(NSArray *)fileTypes
{
	return [NSArray arrayWithObjects:
		@"jpg", // JPEG Image
		@"jpeg",
		@"jpe",
		NSFileTypeForHFSTypeCode('JPEG'),

		@"png", // Portable Network Graphics
		NSFileTypeForHFSTypeCode('PNG '),
		NSFileTypeForHFSTypeCode('PNGf'),

		@"gif", // Graphics Interchange Format
		NSFileTypeForHFSTypeCode('GIFf'),
		NSFileTypeForHFSTypeCode('GIF '),

		@"tif", // TIFF Image
		@"tiff", 
		NSFileTypeForHFSTypeCode('TIFF'),

		@"bmp", // Windows Bitmap Image
		@"dib", //?
		NSFileTypeForHFSTypeCode('BMP '),
		NSFileTypeForHFSTypeCode('BMPf'),
		NSFileTypeForHFSTypeCode('BMPp'),

		@"psd", // Adobe Photoshop Image
		NSFileTypeForHFSTypeCode('8BPS'),

		@"tga", // Targa Image
		NSFileTypeForHFSTypeCode('TPIC'),

		@"jp2", // JPEG 2000 Image
		NSFileTypeForHFSTypeCode('jp2 '),

		@"pict", // PICT Image
		@"pct", 
		@"pic",
		NSFileTypeForHFSTypeCode('PICT'),

		@"fpx", // FlashPix Image
		@"'FPix'", 

		@"qtif", // Apple Quicktime Image
		@"qti",
		@"qif", 
		NSFileTypeForHFSTypeCode('qtif'),

		@"sgi", // Silicon Graphics Image
		NSFileTypeForHFSTypeCode('SGI '),
		NSFileTypeForHFSTypeCode('.SGI'),

		@"pntg", // Apple MacPaint image
		NSFileTypeForHFSTypeCode('PNTG'), 

		@"mac", //?

		nil
	];
}


@end

static void XeeSetQTDepth(XeeImage *image,int qtdepth)
{
	if(qtdepth<=8) [image setDepthIndexed:(1<<qtdepth)];
	else if(qtdepth>32) [image setDepthGrey:qtdepth-32];
	else if(qtdepth==15) [image setDepth:@"5:5:5 bit RGB" iconName:@"depth/rgb"];
	else if(qtdepth==16) [image setDepth:@"1:5:5:5 bit ARGB" iconName:@"depth/rgba"];
	else if(qtdepth==24) [image setDepthRGB:8];
	else if(qtdepth==32) [image setDepthRGBA:8];
}

static OSErr XeeQTProgressFunc(short message,Fixed completeness,long refcon)
{
	XeeQuicktimeImage *image=(XeeQuicktimeImage *)refcon; // ow ow ow, 64-bit issues!

	if ([image hasBeenStopped]) {
		return codecAbortErr;
	}

	return noErr;
}

#endif
