#import "XeeImageThumbnailing.h"

@implementation XeeImage (Thumbnailing)

-(CGImageRef)makeRGBThumbnailOfSize:(int)size
{
	CGImageRef cgimage=[self createCGImage];
	CGImageRef thumbnail=NULL;

	if (cgimage) {
		size_t cgwidth=CGImageGetWidth(cgimage);
		size_t cgheight=CGImageGetHeight(cgimage);
		size_t thumbwidth,thumbheight;

		if (cgwidth > cgheight) {
			thumbwidth = size;
			thumbheight = (size * cgheight) / cgwidth;
		} else {
			thumbwidth = (size * cgwidth) / cgheight;
			thumbheight = size;
		}

		NSMutableData *thumbdata = [NSMutableData dataWithLength:thumbwidth * thumbheight * 4];
		if (thumbdata) {
			CGContextRef context=CGBitmapContextCreate(thumbdata.mutableBytes,
			thumbwidth,thumbheight, 8, thumbwidth * 4,CGImageGetColorSpace(cgimage),
			kCGImageAlphaPremultipliedLast);
			if (context) {
				CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
				CGContextDrawImage(context, CGRectMake(0, 0, thumbwidth, thumbheight), cgimage);
				thumbnail = CGBitmapContextCreateImage(context);

				CGContextRelease(context);
			}
			CFRelease(thumbdata);
		}
		CGImageRelease(cgimage);
	}
	return thumbnail;
}

-(NSData *)makeJPEGThumbnailOfSize:(int)size maxBytes:(int)maxbytes
{
	CGImageRef thumbnail=[self makeRGBThumbnailOfSize:size];
	if (!thumbnail) {
		return NULL;
	}

	NSData *thumbdata=NULL;
	int quality = 60;
	do {
		NSMutableData *data = [[NSMutableData alloc] init];
		if (data) {
			CGImageDestinationRef dest = CGImageDestinationCreateWithData((CFMutableDataRef)data,
																		  kUTTypeJPEG, 1, NULL);
			if (dest) {
				NSDictionary *options = @{(NSString *)kCGImageDestinationLossyCompressionQuality:
											  @((float)quality/100.0)};

				CGImageDestinationAddImage(dest, thumbnail, (CFDictionaryRef)options);

				if (CGImageDestinationFinalize(dest)) {
					if (data.length < maxbytes) {
						thumbdata = [data copy];
					}
				}
				CFRelease(dest);
			}
			[data release];
		}
		quality -= 10;
	} while (!thumbdata && quality > 0);

	if (thumbdata)
		return [thumbdata autorelease];

	return nil;
}

@end
