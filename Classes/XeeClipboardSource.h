#import "XeeImageSource.h"

@interface XeeClipboardSource:XeeImageSource
{
	XeeImage *image;
	uint64_t size;
}

+(BOOL)canInitWithPasteboard:(NSPasteboard *)pboard;
@property (class, readonly) BOOL canInitWithGeneralPasteboard;

-(instancetype)initWithPasteboard:(NSPasteboard *)pboard;
-(instancetype)initWithGeneralPasteboard;

@property (readonly) NSInteger numberOfImages;
-(NSInteger)indexOfCurrentImage;
@property (readonly, retain) NSString *windowTitle;
@property (readonly, retain) NSString *descriptiveNameOfCurrentImage;
@property (readonly) uint64_t sizeOfCurrentImage;

-(void)pickImageAtIndex:(int)index next:(int)next;

@end
