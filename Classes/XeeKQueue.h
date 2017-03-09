#import <Cocoa/Cocoa.h>
#import <sys/event.h>

#import "XeeFSRef.h"

NS_ASSUME_NONNULL_BEGIN

@interface XeeKQueue:NSObject
{
	int queue;
	NSMutableDictionary *observers;
}

-(id)init;

-(void)addObserver:(id)observer selector:(SEL)selector ref:(XeeFSRef *)ref;
-(void)addObserver:(id)observer selector:(SEL)selector ref:(XeeFSRef *)ref flags:(int)flags;
-(void)removeObserver:(id)observer ref:(XeeFSRef *)ref;

-(void)eventLoop;

+(XeeKQueue *)defaultKQueue;
@property (class, readonly, retain) XeeKQueue *defaultKQueue;

@end



@interface XeeKEvent:NSObject
{
	int fd;
	XeeFSRef *ref;
	__unsafe_unretained id target;
	SEL sel;
	struct kevent ev;
}

-(id)initWithFileDescriptor:(int)filedesc observer:(id)observer selector:(SEL)selector ref:(XeeFSRef *)ref;

@property (readonly) int fileDescriptor;
@property (readonly, retain) XeeFSRef *ref;
@property (readonly) int flags;
-(void)triggerForEvent:(struct kevent *)event;

@end



@interface XeeKEventKey:NSObject <NSCopying>
{
	XeeFSRef *ref;
	id target;
}

+(XeeKEventKey *)keyWithRef:(XeeFSRef *)fsref target:(id)observer;

-(instancetype)initWithRef:(XeeFSRef *)fsref target:(id)observer;
@property (readonly, assign) XeeFSRef *ref;
@property (readonly, assign) id target;

@end

NS_ASSUME_NONNULL_END
