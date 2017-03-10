#import <Cocoa/Cocoa.h>
#import "XeeTypes.h"

@interface XeeDuckyParser:NSObject
{
	NSMutableArray *props;
}

-(instancetype)initWithBuffer:(uint8_t *)duckydata length:(int)len;

-(NSArray *)propertyArray;

@end
