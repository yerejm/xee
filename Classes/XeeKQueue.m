#import "XeeKQueue.h"

#include <unistd.h>


@implementation XeeKQueue

-(id)init
{
	if(self=[super init])
	{
		observers=[[NSMutableDictionary alloc] init];

		queue=kqueue();
		if(queue==-1)
		{
			[self release];
			return nil;
		}

		[NSThread detachNewThreadSelector:@selector(eventLoop) toTarget:self withObject:nil];
	}

	return self;
}

-(void)dealloc
{
	[observers release];

	if(queue>0) close(queue);

	[super dealloc];
}

-(void)addObserver:(id)observer selector:(SEL)selector ref:(XeeFSRef *)ref
{
	[self addObserver:observer selector:selector ref:ref
	flags:NOTE_DELETE|NOTE_WRITE|NOTE_EXTEND|NOTE_ATTRIB|NOTE_LINK|NOTE_RENAME|NOTE_REVOKE];
}

-(void)addObserver:(id)observer selector:(SEL)selector ref:(XeeFSRef *)ref flags:(int)flags;
{
	int fd=open([[ref path] fileSystemRepresentation],O_EVTONLY,0);
	if(fd<0) return;

	XeeKEvent *event=[[[XeeKEvent alloc] initWithFileDescriptor:fd observer:observer selector:selector ref:ref] autorelease];

	struct kevent ev;
	EV_SET(&ev,fd,EVFILT_VNODE,(EV_ADD|EV_ENABLE|EV_CLEAR),flags,0,event);

	if(kevent(queue,&ev,1,NULL,0,NULL)==-1)
	{
		close(fd);
		return;
	}

	[observers setObject:event forKey:(id)[XeeKEventKey keyWithRef:ref target:observer]];
}

-(void)removeObserver:(id)observer ref:(XeeFSRef *)ref
{
	if(!observer||!ref) return;

	id key=[XeeKEventKey keyWithRef:ref target:observer];
	XeeKEvent *event=[observers objectForKey:key];
	if(!event) return;

	close([event fileDescriptor]);
	[observers removeObjectForKey:key];
}

-(void)eventLoop
{
	@autoreleasepool {
	[NSThread currentThread].name = @"XeeKQueue";

	for(;;)
	{
		struct kevent ev;
		int n=kevent(queue,NULL,0,&ev,1,NULL);

		while(n)
		{
			XeeKEvent *event=(XeeKEvent *)ev.udata;
			[event triggerForEvent:&ev];

			struct timespec spec={0,0};
			n=kevent(queue,NULL,0,&ev,1,&spec);
		}
	}
	
	}
}

+(XeeKQueue *)defaultKQueue
{
	static XeeKQueue *kqueue=nil;
	if (!kqueue) {
		kqueue = [[XeeKQueue alloc] init];
	}
	return kqueue;
}

@end



@implementation XeeKEvent
@synthesize fileDescriptor = fd;
@synthesize ref;

-(id)initWithFileDescriptor:(int)filedesc observer:(id)observer selector:(SEL)selector ref:(XeeFSRef *)fsref
{
	if(self=[super init])
	{
		fd=filedesc;
		target=observer;
		sel=selector;
		ref=[fsref retain];
	}
	return self;
}

-(void)dealloc
{
	[ref release];
	[super dealloc];
}

-(int)flags
{
	return ev.fflags;
}

-(void)triggerForEvent:(struct kevent *)event
{
	ev=*event;
	[target performSelectorOnMainThread:sel withObject:self waitUntilDone:NO];
}

@end



@implementation XeeKEventKey
@synthesize ref;
@synthesize target;

+(XeeKEventKey *)keyWithRef:(XeeFSRef *)fsref target:(id)observer
{
	return [[[self alloc] initWithRef:fsref target:observer] autorelease];
}

-(id)initWithRef:(XeeFSRef *)fsref target:(id)observer
{
	if(self=[super init])
	{
		ref=fsref;
		target=observer;
	}
	return self;
}

-(BOOL)isEqual:(XeeKEventKey *)other
{
	if(![other isKindOfClass:[self class]]) return NO;
	return [ref isEqual:[other ref]]&&target==[other target];
}

-(NSUInteger)hash
{
	return (uintptr_t)target;
}

-(id)copyWithZone:(NSZone *)zone
{
	return [[XeeKEventKey allocWithZone:zone] initWithRef:ref target:target];
}

@end
