#include <Availability.h>
#import <Foundation/Foundation.h>
#ifndef MAC_OS_X_VERSION_MIN_REQUIRED
#define MAC_OS_X_VERSION_MIN_REQUIRED MAC_OS_X_VERSION_10_1
#endif
#ifndef MAC_OS_X_VERSION_MAX_ALLOWED
#define MAC_OS_X_VERSION_MAX_ALLOWED MAC_OS_X_VERSION_10_4
#endif
#import "CSCoroutine.h"
#include <pthread.h>
#include <objc/runtime.h>
#include <objc/message.h>

@interface NSProxy (Hidden)
- (void)doesNotRecognizeSelector:(SEL)sel;
@end

static pthread_key_t currkey, mainkey;

static void CSCoroutineFreeMain(CSCoroutine *main)
{
	[main release];
}

static CSCoroutine *CSMainCoroutine()
{
	CSCoroutine *main = (CSCoroutine *)pthread_getspecific(mainkey);
	if (!main) {
		main = [[CSCoroutine alloc] initWithTarget:nil stackSize:0];
		pthread_setspecific(mainkey, main);
	}
	return main;
}

static CSCoroutine *CSCurrentCoroutine()
{
	CSCoroutine *curr = (CSCoroutine *)pthread_getspecific(currkey);
	if (curr) {
		return curr;
	} else {
		return CSMainCoroutine();
	}
}

static CSCoroutine *CSSetCurrentCoroutine(CSCoroutine *new)
{
	CSCoroutine *curr = CSCurrentCoroutine();
	pthread_setspecific(currkey, new);
	return curr;
}

static void CSSetEntryPoint(jmp_buf env, void (*entry)(), void *stack, long stacksize)
{
#if defined(__i386__)
	env[9] = (((int)stack + stacksize) & ~15) - 4; // -4 to pretend that a return address has just been pushed onto the stack
	env[12] = (int)entry;
#elif defined(__x86_64__)
#warning TODO: implement!
#elif defined(__ppc__)
	env[0] = ((int)stack + stacksize - 64) & ~3;
	env[21] = (int)entry;
#else
#error unknown architecture
#endif
}

@implementation CSCoroutine

+ (void)initialize
{
	pthread_key_create(&currkey, NULL);
	pthread_key_create(&mainkey, (void (*)(void*))CSCoroutineFreeMain);
}

+ (CSCoroutine *)mainCoroutine
{
	return CSMainCoroutine();
}

+ (CSCoroutine *)currentCoroutine
{
	return CSCurrentCoroutine();
}

+ (void)setCurrentCoroutine:(CSCoroutine *)curr
{
	CSSetCurrentCoroutine(curr);
}

+ (void)returnFromCurrent
{
	[CSCurrentCoroutine() returnFrom];
}

- (id)initWithTarget:(id)targetobj stackSize:(size_t)stackbytes
{
	target = targetobj;
	stacksize = stackbytes;
	if (stacksize) {
		stack = malloc(stacksize);
	}
	fired = target ? NO : YES;

	caller = nil;
	inv = nil;

	return self;
}

- (void)dealloc
{
	free(stack);
	[inv release];
	[super dealloc];
}

- (void)switchTo
{
	CSCoroutine *curr = CSSetCurrentCoroutine(self);
	caller = curr;
	if (_setjmp(curr->env) == 0) {
		_longjmp(env, 1);
	}
}

- (void)returnFrom
{
	/*CSCoroutine *curr=*/CSSetCurrentCoroutine(caller);
	if (_setjmp(env) == 0) {
		_longjmp(caller->env, 1);
	}
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)sel
{
	return [target methodSignatureForSelector:sel];
}

static void CSLeopardCoroutineStart()
{
	CSCoroutine *coro = CSCurrentCoroutine();
	[coro->inv invoke];
	[coro returnFrom];
	[NSException raise:@"CSCoroutineException" format:@"Attempted to switch to a coroutine that has ended"];
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
	if (fired) {
		[NSException raise:@"CSCoroutineException" format:@"Attempted to start a coroutine that is already running"];
	}
	fired = YES;

	inv = [invocation retain];
	[inv setTarget:target];

	_setjmp(env);
	CSSetEntryPoint(env, CSLeopardCoroutineStart, stack, stacksize);

	[self switchTo];
}

@end

@implementation NSObject (CSCoroutine)

- (CSCoroutine *)newCoroutine
{
	return [[CSCoroutine alloc] initWithTarget:self stackSize:1024 * 1024];
}

- (CSCoroutine *)newCoroutineWithStackSize:(size_t)stacksize
{
	return [[CSCoroutine alloc] initWithTarget:self stackSize:stacksize];
}

@end
