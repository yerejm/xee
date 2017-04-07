//
//  XeeTests.m
//  XeeTests
//
//  Created by C.W. Betts on 3/28/17.
//
//

#import <XCTest/XCTest.h>
#import "CSCoroutine.h"

@interface XeeCoroutineTests : XCTestCase {
	NSConditionLock *lock;
	int test1block1[6];
	int test1block2[6];
}

@end

@implementation XeeCoroutineTests

- (void)setUp {
    [super setUp];

	memset(test1block1, 0, sizeof(test1block1));
	memset(test1block2, 0, sizeof(test1block2));
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testInterleavedLoops
{
	[self test1:10];
	for (int i = 0; i < 6; i++) {
		XCTAssertEqual(test1block1[i] + test1block2[i], 20, @"iteration %d", i);
	}
}

- (void)test1:(int)val
{
	printf("Test 1: Interleaved loops\n");
	
	// Create and start coroutine which will return immediately.
	CSCoroutine *coro = [self newCoroutine];
	[(id)coro test1b:val];
	
	// Print five numbers, invoking the coroutine after each.
	for (int i = 0; i <= 5; i++) {
		int newVal = val + i;
		test1block1[i] = newVal;
		printf("a: %d\n", newVal);
		[coro switchTo];
	}
	
	[coro release];
}

- (void)test1b:(int)val
{
	// Return immediately to let main function run.
	[CSCoroutine returnFromCurrent];
	
	// Print five numbers, returning after each one
	for (int i = 0; i <= 5; i++) {
		int newVal = val - i;
		test1block2[i] = newVal;
		printf("b: %d\n", newVal);
		[CSCoroutine returnFromCurrent];
	}
}


- (void)testExceptions
{
	// Save the current coroutine pointer before calling potentially
	// exception-throwing coroutine.
	CSCoroutine *savedcoro = [CSCoroutine currentCoroutine];
	BOOL assertWasCaught = NO;
	
	@try {
		// Create and start coroutine which will throw an exception.
		CSCoroutine *coro = [self newCoroutine];
		[(id)coro subFunc2];
	}
	@catch (id e) {
		// Clean up after the exception by explicitly restoring
		// the current coroutine pointer. This is important!
		[CSCoroutine setCurrentCoroutine:savedcoro];
		printf("Exception caught!\n");
		assertWasCaught = YES;
	}
	XCTAssertTrue(assertWasCaught);
}

- (void)subFunc2
{
	printf("In coroutine, throwing exception.\n");
	[NSException raise:@"TestException" format:@"Test"];
}

- (void)testJumpingThreads
{
	// Create and start a coroutine on the main thread.
	CSCoroutine *coro = [self newCoroutine];
	[(id)coro subfunc3c];
	
	// Detach a secondary thread, which will also invoke the same coroutine.
	lock = [[NSConditionLock alloc] initWithCondition:0];
	[NSThread detachNewThreadSelector:@selector(test3b:) toTarget:self withObject:coro];
	
	// Wait until thread finishes.
	[lock lockWhenCondition:1];
	[lock unlock];
	[lock release];

}

- (void)test3b:(CSCoroutine *)coro
{
	printf("Separate thread started\n");
	
	// Invoke the coroutine created earlier, then clean up and exit.
	[coro switchTo];
	[coro release];
	[lock lockWhenCondition:0];
	[lock unlockWithCondition:1];
}

- (void)subfunc3c
{
	printf("First invocation in main thread.\n");
	[CSCoroutine returnFromCurrent];
	printf("Second invocation in separate thread.\n");
}

@end
