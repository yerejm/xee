#import <Foundation/Foundation.h>
#include <setjmp.h>
#include <objc/runtime.h>
#include <objc/message.h>

@interface CSCoroutine : NSProxy {
	id target;
	size_t stacksize;
	void *stack;
	BOOL fired;

	CSCoroutine *caller;
	jmp_buf env;

	NSInvocation *inv;
}
@property (class, readonly, retain) CSCoroutine *mainCoroutine;
@property (class, retain) CSCoroutine *currentCoroutine;
+ (void)returnFromCurrent;

- (instancetype)initWithTarget:(id)targetobj stackSize:(size_t)stackbytes;
- (void)dealloc;

- (void)switchTo;
- (void)returnFrom;
@end

@interface NSObject (CSCoroutine)
- (CSCoroutine *)newCoroutine;
- (CSCoroutine *)newCoroutineWithStackSize:(size_t)stacksize;
@end
