#import "XeeCGImage.h"


typedef struct CGAccessSession *CGAccessSessionRef;

// Reverse-engineered API calls. Evil!

CGAccessSessionRef CGAccessSessionCreate(CGDataProviderRef provider);
void *CGAccessSessionGetBytePointer(CGAccessSessionRef session);
size_t CGAccessSessionGetBytes(CGAccessSessionRef session,void *buffer,size_t bytes);
void CGAccessSessionRelease(CGAccessSessionRef session);



@implementation XeeCGImage
{
	CGImageRef imageref;
	CGAccessSessionRef session;
}

-(id)init
{
	if(self=[super init])
	{
		imageref=NULL;
		session=NULL;
	}
	return self;
}

-(id)initWithCGImage:(CGImageRef)cgimage
{
	if(self=[super init])
	{
		imageref=NULL;
		session=NULL;

		if(![self setCGImage:cgimage]) {
			return nil;
		}
	}
	return self;
}

-(void)dealloc
{
	if (session)
		CGAccessSessionRelease(session);
	CGImageRelease(imageref);
}

-(BOOL)setCGImage:(CGImageRef)cgimage
{
	if(!cgimage) return NO;

	size_t pixelwidth=CGImageGetWidth(cgimage);
	size_t pixelheight=CGImageGetHeight(cgimage);
	size_t bprow=CGImageGetBytesPerRow(cgimage);
	size_t bppixel=CGImageGetBitsPerPixel(cgimage);
	size_t bpcomponent=CGImageGetBitsPerComponent(cgimage);
	CGBitmapInfo bitmapinfo=CGImageGetBitmapInfo(cgimage); // only on 10.4
	CGImageAlphaInfo alphainfo=CGImageGetAlphaInfo(cgimage);
	CGColorSpaceRef colorspace=CGImageGetColorSpace(cgimage);
	size_t components=CGColorSpaceGetNumberOfComponents(colorspace);

	int mode;
	switch (components) {
		case 1: mode=XeeGreyBitmap; break;
		case 3: mode=XeeRGBBitmap; break;
		default: return NO;
	}

	// Check for unsupported (non-host) byte ordering
	CGBitmapInfo byteorder=bitmapinfo&kCGBitmapByteOrderMask;
	#ifdef __BIG_ENDIAN__
	if(byteorder==kCGBitmapByteOrder16Little||byteorder==kCGBitmapByteOrder32Little) return NO;
	#else
	if(byteorder==kCGBitmapByteOrder16Big||byteorder==kCGBitmapByteOrder32Big) return NO;
	#endif

	CGDataProviderRef provider=CGImageGetDataProvider(cgimage);
	if(!provider)
		return NO;

	CGAccessSessionRef newsession=CGAccessSessionCreate(provider);
	if(!newsession)
		return NO;

	BOOL shouldfree=NO;
	void *pixeldata=CGAccessSessionGetBytePointer(newsession);
	if (!pixeldata) {
		size_t bytes=pixelheight*bprow;
		pixeldata=malloc(bytes);
		if (!pixeldata) {
			CGAccessSessionRelease(newsession);
			return NO;
		}

		/*size_t res=*/CGAccessSessionGetBytes(newsession,pixeldata,bytes);
		// should check res, maybe?

		CGAccessSessionRelease(newsession);
		newsession=NULL;

		shouldfree=YES;
	}

	int flags=0;
	if(bitmapinfo&kCGBitmapFloatComponents) flags|=XeeBitmapFloatingPointFlag;

	if (![self setData:pixeldata freeData:shouldfree width:pixelwidth height:pixelheight
		  bitsPerPixel:bppixel bitsPerComponent:bpcomponent bytesPerRow:bprow
				  mode:mode alphaType:alphainfo flags:flags]) {
		if (newsession) {
			CGAccessSessionRelease(newsession);
		}
		return NO;
	}

	CGImageRetain(cgimage);
	CGImageRelease(imageref);
	imageref=cgimage;

	if (session)
		CGAccessSessionRelease(session);
	session=newsession;

	return YES;
}

-(void)invertImage
{
	// Used to invert the colours of TIFF bitmap images.

	if(bitspercomponent!=8)
		return; // TODO: should throw an exception?

	for (NSInteger y = 0; y < height; y++) {
		for (NSInteger i = 0; i < bytesperrow; i++) {
			data[y * bytesperrow + i]^=0xff;
		}
	}
}

-(CGColorSpaceRef)createColorSpaceForCGImage
{
	if (!imageref)
		return [super createColorSpaceForCGImage];

	CGColorSpaceRef colorspace=CGImageGetColorSpace(imageref);

	if (colorspace)
		CGColorSpaceRetain(colorspace);

	return colorspace;
}

@end
