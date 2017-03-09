#import <Cocoa/Cocoa.h>

@interface XeePropertyItem:NSObject
{
	NSString *label;
	id value;
	NSString *ident;

	XeePropertyItem *heading;
	int pos;
}

+(XeePropertyItem *)itemWithLabel:(NSString *)itemlabel value:(id)itemvalue;
+(XeePropertyItem *)itemWithLabel:(NSString *)itemlabel value:(id)itemvalue identifier:(NSString *)identifier;
+(XeePropertyItem *)itemWithLabel:(NSString *)itemlabel value:(id)itemvalue heading:(XeePropertyItem *)headingitem position:(int)position;
+(XeePropertyItem *)subSectionItemWithLabel:(NSString *)itemlabel identifier:(NSString *)identifier labelsAndValues:(id)first,... NS_REQUIRES_NIL_TERMINATION;
+(NSArray<XeePropertyItem *> *)itemsWithLabel:(NSString *)itemlabel valueArray:(NSArray *)values;
+(NSArray<XeePropertyItem *> *)itemsWithLabel:(NSString *)itemlabel values:(id)first,... NS_REQUIRES_NIL_TERMINATION;
+(NSArray<XeePropertyItem *> *)itemsWithLabel:(NSString *)itemlabel textValue:(NSString *)text;

-(id)initWithLabel:(NSString *)itemlabel value:(id)itemvalue identifier:(NSString *)identifier heading:(XeePropertyItem *)headingitem position:(int)position;
-(void)dealloc;

-(NSString *)label;
-(id)value;
-(NSString *)identifier;
-(XeePropertyItem *)heading;
-(int)position;
-(BOOL)isSubSection;

-(NSComparisonResult)compare:(XeePropertyItem *)other;

@end
