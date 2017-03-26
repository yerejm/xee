#import <Cocoa/Cocoa.h>
#import "XeeParser.h"
#import <XADMaster/CSHandle.h>

//#import <xml.h>
@class XeePropertyItem;

@interface XeeXMPParser : NSObject <XeeParser> {
	NSMutableArray *props;
	NSDictionary *prefixdict, *localnamedict;
}

- (id)initWithHandle:(CSHandle *)handle;

- (NSString *)parsePropertyName:(NSXMLNode *)node;
- (NSArray<NSString *> *)parsePropertyValue:(NSXMLNode *)node;
- (NSString *)parseSingleValue:(NSXMLNode *)node;

- (NSString *)reflowName:(NSString *)name
			  capitalize:(BOOL)capitalize
			  exceptions:(NSDictionary *)exceptions;

- (NSArray<XeePropertyItem *> *)propertyArray;

@end
