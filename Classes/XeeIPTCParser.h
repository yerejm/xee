#import <Cocoa/Cocoa.h>
#import "XeeParser.h"
#import <XADMaster/CSHandle.h>

@interface XeeIPTCParser:NSObject <XeeParser>
{
	NSMutableArray *props;
}

-(id)initWithHandle:(CSHandle *)handle;

-(NSArray<XeePropertyItem*> *)propertyArray;

@end
