#import "XeeImageSource.h"
#import "XeePrefKeys.h"

#import <pthread.h>

NSString *XeeErrorDomain = @"XeeErrorDomain";

@implementation XeeImageSource
@synthesize delegate;
@synthesize icon;
@synthesize sortOrder = sortorder;

- (id)init
{
	if (self = [super init]) {
		delegate = nil;
		icon = nil;
		sortorder = [[NSUserDefaults standardUserDefaults] integerForKey:XeeDefaultSortingOrderKey];

		actionsblocked = NO;
		pendingimagechange = NO;
		pendinglistchange = NO;
		pendingimage = nil;

		rand_ordering = NULL;
		rand_size = 0;
	}
	return self;
}

- (void)dealloc
{
	free(rand_ordering);
	[icon release];
	[pendingimage release];
	[super dealloc];
}

- (void)start
{
}

- (void)stop
{
}

- (NSInteger)numberOfImages
{
	return 0;
}

- (NSInteger)indexOfCurrentImage
{
	return 0;
}

- (NSString *)windowTitle
{
	return nil;
}

- (NSString *)windowRepresentedFilename
{
	return nil;
}

- (NSString *)descriptiveNameOfCurrentImage
{
	return nil;
}

- (NSString *)filenameOfCurrentImage
{
	return nil;
}

- (uint64_t)sizeOfCurrentImage
{
	return 0;
}

- (NSDate *)dateOfCurrentImage
{
	return nil;
}

- (BOOL)isCurrentImageRemote
{
	return NO;
}

- (BOOL)isCurrentImageAtPath:(NSString *)path
{
	return NO;
}

- (BOOL)canBrowse
{
	return NO;
}
- (BOOL)canSort
{
	return NO;
}
- (BOOL)canRenameCurrentImage
{
	return NO;
}
- (BOOL)canDeleteCurrentImage
{
	return NO;
}
- (BOOL)canCopyCurrentImage
{
	return NO;
}
- (BOOL)canMoveCurrentImage
{
	return NO;
}
- (BOOL)canOpenCurrentImage
{
	return NO;
}
- (BOOL)canSaveCurrentImage
{
	return NO;
}

- (XeeSortOrder)sortOrder
{
	return sortorder == XeeDefaultSortOrder ? XeeNameSortOrder : sortorder;
}

- (void)setActionsBlocked:(BOOL)blocked
{
	if (actionsblocked && !blocked) {
		actionsblocked = NO;
		if (pendingimagechange) {
			[self triggerImageChangeAction:pendingimage];
			[pendingimage release];
			pendingimage = nil;
			pendingimagechange = NO;
		}

		if (pendinglistchange) {
			[self triggerImageListChangeAction];
			pendinglistchange = NO;
		}
	} else
		actionsblocked = blocked;
}

- (void)pickImageAtIndex:(NSInteger)index next:(NSInteger)next
{
}

- (void)pickImageAtIndex:(NSInteger)index
{
	NSInteger curr = [self indexOfCurrentImage];
	NSInteger count = [self numberOfImages];

	NSInteger next;
	if (index == count - 1)
		next = count - 2;
	else if (index == 0)
		next = 1;
	else if (index < curr)
		next = index - 1;
	else
		next = index + 1;

	[self pickImageAtIndex:index next:next];
}

- (void)skip:(NSInteger)offset
{
	NSInteger curr = [self indexOfCurrentImage];
	NSInteger count = [self numberOfImages];
	if (count == 0) {
		return;
	}
	if (curr == NSNotFound) {
		if (offset >= 0)
			[self pickFirstImage];
		else
			[self pickLastImage];
	} else {
		NSInteger newpos = curr + offset;
		if ([[NSUserDefaults standardUserDefaults] boolForKey:@"wrapImageBrowsing"]) {
			newpos = (newpos % count + count) % count; // this looks horrible
		} else {
			if (newpos < 0)
				newpos = 0;
			if (newpos >= count)
				newpos = count - 1;
		}
		if (newpos != curr)
			[self pickImageAtIndex:newpos];
	}
}

- (void)pickFirstImage
{
	[self pickImageAtIndex:0];
}

- (void)pickLastImage
{
	[self pickImageAtIndex:[self numberOfImages] - 1];
}

- (void)pickNextImageAtRandom
{
	NSInteger index = [self indexOfCurrentImage];
	if (index == NSNotFound) {
		NSInteger count = [self numberOfImages];
		if (count)
			[self pickImageAtIndex:random() % count];
	} else {
		[self updateRandomList];
		if (rand_ordering)
			[self pickImageAtIndex:rand_ordering[index].next
							  next:rand_ordering[rand_ordering[index].next].next];
	}
}

- (void)pickPreviousImageAtRandom
{
	NSInteger index = [self indexOfCurrentImage];
	if (index == NSNotFound) {
		NSInteger count = [self numberOfImages];
		if (count)
			[self pickImageAtIndex:random() % count];
	} else {
		[self updateRandomList];
		if (rand_ordering)
			[self pickImageAtIndex:rand_ordering[index].prev
							  next:rand_ordering[rand_ordering[index].prev].prev];
	}
}

- (void)pickCurrentImage
{
	[self pickImageAtIndex:[self indexOfCurrentImage]];
}

- (NSError *)renameCurrentImageTo:(NSString *)newname
{
	return [NSError errorWithDomain:XeeErrorDomain code:XeeNotSupportedError userInfo:nil];
}
- (NSError *)deleteCurrentImage
{
	return [NSError errorWithDomain:XeeErrorDomain code:XeeNotSupportedError userInfo:nil];
}
- (NSError *)copyCurrentImageTo:(NSString *)destination
{
	return [NSError errorWithDomain:XeeErrorDomain code:XeeNotSupportedError userInfo:nil];
}
- (NSError *)moveCurrentImageTo:(NSString *)destination
{
	return [NSError errorWithDomain:XeeErrorDomain code:XeeNotSupportedError userInfo:nil];
}
- (NSError *)openCurrentImageInApp:(NSString *)app
{
	return [NSError errorWithDomain:XeeErrorDomain code:XeeNotSupportedError userInfo:nil];
}

- (void)beginSavingImage:(XeeImage *)image
{
}
- (void)endSavingImage:(XeeImage *)image
{
}

- (void)updateRandomList
{
	NSInteger length = [self numberOfImages];
	if (rand_ordering && length == rand_size)
		return;

	free(rand_ordering);

	srandom(0x7fffffff & time(NULL));

	NSInteger *order = malloc(sizeof(NSInteger) * length);
	rand_ordering = malloc(sizeof(struct rand_entry) * length);
	if (!rand_ordering) {
		free(order);
		return;
	}
	rand_size = length;

	for (NSInteger i = 0; i < length; i++)
		order[i] = i;

	for (NSInteger i = length - 1; i > 0; i--) {
		NSInteger randindex = random() % i;
		NSInteger tmp = order[i];
		order[i] = order[randindex];
		order[randindex] = tmp;
	}

	for (int i = 0; i < length; i++) {
		rand_ordering[order[i]].next = order[(i + 1) % length];
		rand_ordering[order[i]].prev = order[(i + length - 1) % length];
	}

	free(order);
}

- (void)triggerImageChangeAction:(XeeImage *)image
{
	if (actionsblocked) {
		if (image != pendingimage) {
			[pendingimage release];
			pendingimage = [image retain];
		}
		pendingimagechange = YES;
	} else {
		[delegate xeeImageSource:self imageDidChange:image];
		/*		if(pthread_main_np()) [delegate xeeImageSource:self imageDidChange:image];
		else
		{
			NSInvocation *invocation=[NSInvocation invocationWithMethodSignature:[delegate methodSignatureForSelector:@selector(XeeImageSource:imageDidChange:)]];
			[invocation setArgument: atIndex:
		}

		else [delegate performSelectorOnMainThread:@selector(xeeImagePropertiesDidChange:) withObject:self waitUntilDone:NO];
*/
	}
}

- (void)triggerImageListChangeAction
{
	if (actionsblocked)
		pendinglistchange = YES;
	else
		[delegate xeeImageSource:self imageListDidChange:[self numberOfImages]];
}

- (NSString *)demandPassword
{
	return [delegate xeeImageSourceDemandsPassword:self];
}

@end

@implementation NSObject (XeeImageSourceDelegate)

- (void)xeeImageSource:(XeeImageSource *)source imageListDidChange:(int)num
{
}
- (void)xeeImageSource:(XeeImageSource *)source imageDidChange:(XeeImage *)newimage
{
}
- (NSString *)xeeImageSourceDemandsPassword:(XeeImageSource *)source
{
	return nil;
}

@end
