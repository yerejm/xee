#import <Foundation/Foundation.h>

@interface XeePropertyItem : NSObject {
	NSString *label;
	id value;
	NSString *ident;

	XeePropertyItem *heading;
	int pos;
}

+ (instancetype)itemWithLabel:(NSString *)itemlabel value:(id)itemvalue;
+ (instancetype)itemWithLabel:(NSString *)itemlabel value:(id)itemvalue identifier:(NSString *)identifier;
+ (instancetype)itemWithLabel:(NSString *)itemlabel value:(id)itemvalue heading:(XeePropertyItem *)headingitem position:(int)position;
+ (instancetype)subSectionItemWithLabel:(NSString *)itemlabel identifier:(NSString *)identifier labelsAndValues:(id)first, ... NS_REQUIRES_NIL_TERMINATION;
+ (NSArray<XeePropertyItem *> *)itemsWithLabel:(NSString *)itemlabel valueArray:(NSArray *)values;
+ (NSArray<XeePropertyItem *> *)itemsWithLabel:(NSString *)itemlabel values:(id)first, ... NS_REQUIRES_NIL_TERMINATION;
+ (NSArray<XeePropertyItem *> *)itemsWithLabel:(NSString *)itemlabel textValue:(NSString *)text;

- (instancetype)initWithLabel:(NSString *)itemlabel value:(id)itemvalue identifier:(NSString *)identifier heading:(XeePropertyItem *)headingitem position:(int)position NS_DESIGNATED_INITIALIZER;
- (instancetype)init UNAVAILABLE_ATTRIBUTE;

@property (readonly, copy) NSString *label;
@property (readonly, strong) id value;
@property (readonly, copy) NSString *identifier;
@property (readonly, strong) XeePropertyItem *heading;
@property (readonly) int position;
@property (readonly, getter=isSubSection) BOOL subSection;

- (NSComparisonResult)compare:(XeePropertyItem *)other;

@end
