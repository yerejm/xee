#import <Cocoa/Cocoa.h>

typedef struct XeeSamplePoint {
	float u, v, weight;
} XeeSamplePoint;
typedef float (*XeeFilterFunction)(float, float);

@interface XeeSampleSet : NSObject {
	XeeSamplePoint *samples;
	NSInteger num;
}

- (instancetype)initWithCount:(NSInteger)count;

- (void)filterWithFunction:(XeeFilterFunction)filter;
- (void)sortByWeight;

@property (readonly) NSInteger count;
- (XeeSamplePoint *)samples;

+ (XeeSampleSet *)sampleSetWithCount:(NSInteger)count
						distribution:(NSString *)distname
							  filter:(NSString *)filtername;

@end
