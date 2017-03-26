#import <Cocoa/Cocoa.h>
#import "XeeParser.h"
#import "XeeTypes.h"

@interface XeeDuckyParser : NSObject <XeeParser> {
	NSMutableArray *props;
}

- (instancetype)initWithBuffer:(uint8_t *)duckydata length:(int)len;

- (NSArray<XeePropertyItem *> *)propertyArray;

@end
