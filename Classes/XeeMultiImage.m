#import "XeeMultiImage.h"

@implementation XeeMultiImage
@dynamic backgroundColor;

- (id)init
{
	if (self = [super init]) {
		subimages = [[NSMutableArray alloc] init];
		currindex = 0;
		currloading = nil;

		if (!subimages) {
			return nil;
		}
	}

	return self;
}

- (void)addSubImage:(XeeImage *)subimage
{
	//[subimage setFilename:filename];
	[subimages addObject:subimage];
	[subimage setDelegate:self];
	if (correctorientation)
		[subimage setCorrectOrientation:correctorientation];
}

- (void)addSubImages:(NSArray *)array
{
	NSEnumerator *enumerator = [array objectEnumerator];
	XeeImage *image;
	while (image = [enumerator nextObject])
		[self addSubImage:image];
}

- (XeeImage *)currentSubImage
{
	if ([subimages count] == 0)
		return nil;
	else
		return [subimages objectAtIndex:currindex];
}

- (void)xeeImageLoadingProgress:(XeeImage *)subimage
{
	if (!subimages || [subimages count] == 0)
		return; // pretty unlikely
	if (subimage == [subimages objectAtIndex:currindex])
		[self triggerLoadingAction];
}

- (void)xeeImageDidChange:(XeeImage *)subimage
{
	if (!subimages || [subimages count] == 0)
		return; // pretty unlikely
	if (subimage == [subimages objectAtIndex:currindex])
		[self triggerChangeAction];
}

- (void)xeeImageSizeDidChange:(XeeImage *)subimage
{
	if (!subimages || [subimages count] == 0)
		return; // pretty unlikely
	if (subimage == [subimages objectAtIndex:currindex])
		[self triggerSizeChangeAction];
}

- (void)xeeImagePropertiesDidChange:(XeeImage *)subimage
{
	if (!subimages || [subimages count] == 0)
		return; // pretty unlikely
	if (subimage == [subimages objectAtIndex:currindex])
		[self triggerPropertyChangeAction];
}

/*-(BOOL)loaded;
-(BOOL)failed;*/

- (BOOL)needsLoading
{
	// check subimages here
	return [super needsLoading];
}

- (void)stopLoading
{
	// order?
	if (currloading)
		[currloading stopLoading];
	[super stopLoading];
}

- (void)runLoaderOnSubImage:(XeeImage *)image
{
	currloading = image;

	while ([currloading needsLoading]) {
		[currloading runLoader];
		XeeImageLoaderYield();
	}

	currloading = nil;
}

- (NSInteger)frames
{
	NSEnumerator *enumerator = [subimages objectEnumerator];
	XeeImage *image;
	int frames = 0;
	while (image = [enumerator nextObject])
		frames += [image frames];
	return frames;
}

- (void)setFrame:(NSInteger)frame
{
	if ([subimages count] == 0)
		return;

	if (frame < 0)
		frame = 0;
	if (frame == [self frame])
		return;

	NSInteger count = [subimages count];
	NSInteger newindex, prevframes = 0;
	for (newindex = 0; newindex < count - 1; newindex++) {
		NSInteger frames = [[subimages objectAtIndex:newindex] frames];
		if (prevframes + frames > frame)
			break;
		else
			prevframes += frames;
	}

	XeeImage *subimage = [subimages objectAtIndex:newindex];
	NSInteger frames = [subimage frames];
	NSInteger subframe = frame - prevframes;
	if (subframe >= frames)
		subframe = frames - 1;

	NSInteger oldwidth = [self width];
	NSInteger oldheight = [self height];

	currindex = newindex;
	[subimage setDelegate:nil];
	[subimage setFrame:subframe];
	[subimage setDelegate:self];

	if (oldwidth != [self width] || oldheight != [self height])
		[self triggerSizeChangeAction];
	else
		[self triggerChangeAction];

	[self triggerPropertyChangeAction];
}

- (NSInteger)frame
{
	NSInteger prevframes = 0;
	for (NSInteger i = 0; i < currindex; i++)
		prevframes += [[subimages objectAtIndex:i] frames];
	return prevframes + [(XeeImage *)[subimages objectAtIndex:currindex] frame];
}

- (NSRect)updatedAreaInRect:(NSRect)rect
{
	XeeImage *curr = [self currentSubImage];
	if (curr)
		return [curr updatedAreaInRect:rect];
	else
		return [super updatedAreaInRect:rect];
}

- (void)drawInRect:(NSRect)rect bounds:(NSRect)bounds lowQuality:(BOOL)lowquality
{
	[[self currentSubImage] drawInRect:rect bounds:bounds lowQuality:lowquality];
}

- (CGImageRef)createCGImage
{
	return [[self currentSubImage] createCGImage];
}

- (XeeSaveFormatFlags)losslessSaveFlags
{
	return [[self currentSubImage] losslessSaveFlags];
}

- (NSString *)losslessFormat
{
	return [[self currentSubImage] losslessFormat];
}

- (NSString *)losslessExtension
{
	return [[self currentSubImage] losslessExtension];
}

- (BOOL)losslessSaveTo:(NSString *)path flags:(XeeSaveFormatFlags)flags
{
	return [[self currentSubImage] losslessSaveTo:path flags:flags];
}

- (NSInteger)width
{
	XeeImage *curr = [self currentSubImage];
	if (curr)
		return [curr width];
	else
		return [super width];
}

- (NSInteger)height
{
	XeeImage *curr = [self currentSubImage];
	if (curr)
		return [curr height];
	else
		return [super height];
}

- (NSInteger)fullWidth
{
	XeeImage *curr = [self currentSubImage];
	if (curr)
		return [curr fullWidth];
	else
		return [super fullWidth];
}

- (NSInteger)fullHeight
{
	XeeImage *curr = [self currentSubImage];
	if (curr)
		return [curr fullHeight];
	else
		return [super fullHeight];
}

- (NSString *)depth
{
	XeeImage *curr = [self currentSubImage];
	NSString *currdepth = [curr depth];
	if (currdepth)
		return currdepth;
	else
		return [super depth];
}

- (NSImage *)depthIcon
{
	XeeImage *curr = [self currentSubImage];
	NSImage *currdepthicon = [curr depthIcon];
	if (currdepthicon)
		return currdepthicon;
	else
		return [super depthIcon];
}

- (BOOL)transparent
{
	XeeImage *curr = [self currentSubImage];
	if (curr)
		return [curr transparent];
	else
		return [super transparent];
}

- (NSColor *)backgroundColor
{
	XeeImage *curr = [self currentSubImage];
	NSColor *background = [curr backgroundColor];
	if (background)
		return background;
	else
		return [super backgroundColor];
}

- (NSRect)croppingRect
{
	XeeImage *curr = [self currentSubImage];
	if (curr)
		return [curr croppingRect];
	else
		return [super croppingRect];
}

- (XeeTransformation)orientation
{
	XeeImage *curr = [self currentSubImage];
	if (curr)
		return [curr orientation];
	else
		return [super orientation];
}

- (XeeTransformation)correctOrientation
{
	XeeImage *curr = [self currentSubImage];
	if (curr)
		return [curr correctOrientation];
	else
		return [super correctOrientation];
}

- (NSArray *)properties
{
	XeeImage *curr = [self currentSubImage];
	NSArray *subproperties = [curr properties];

	if (subproperties) {
		NSMutableArray *array = [NSMutableArray arrayWithArray:subproperties];
		[array addObjectsFromArray:[super properties]];
		return array;
	} else
		return [super properties];
}

- (void)setOrientation:(XeeTransformation)trans
{
	XeeImage *curr = [self currentSubImage];
	if (curr)
		return [curr setOrientation:trans];
	else
		return [super setOrientation:trans];
}

- (void)setCorrectOrientation:(XeeTransformation)trans
{
	NSEnumerator *enumerator = [subimages objectEnumerator];
	XeeImage *subimage;
	while (subimage = [enumerator nextObject])
		[subimage setCorrectOrientation:trans];
	[super setCorrectOrientation:trans];
}

- (void)setCroppingRect:(NSRect)rect
{
	XeeImage *curr = [self currentSubImage];
	if (curr)
		return [curr setCroppingRect:rect];
	else
		return [super setCroppingRect:rect];
}

- (void)resetTransformations
{
	NSEnumerator *enumerator = [subimages objectEnumerator];
	XeeImage *subimage;
	while (subimage = [enumerator nextObject])
		[subimage resetTransformations];
}

@end
