#import "XeeProperties.h"

@implementation XeePropertyItem
@synthesize label;
@synthesize value;
@synthesize identifier = ident;
@synthesize heading;
@synthesize position = pos;


+(XeePropertyItem *)itemWithLabel:(NSString *)itemlabel value:(id)itemvalue
{
	return [[self alloc] initWithLabel:itemlabel value:itemvalue identifier:nil heading:nil position:0];
}

+(XeePropertyItem *)itemWithLabel:(NSString *)itemlabel value:(id)itemvalue identifier:(NSString *)identifier
{
	return [[self alloc] initWithLabel:itemlabel value:itemvalue identifier:identifier heading:nil position:0];
}

+(XeePropertyItem *)itemWithLabel:(NSString *)itemlabel value:(id)itemvalue heading:(XeePropertyItem *)headingitem position:(int)position
{
	return [[self alloc] initWithLabel:itemlabel value:itemvalue identifier:nil heading:headingitem position:position];
}

+(XeePropertyItem *)subSectionItemWithLabel:(NSString *)itemlabel identifier:(NSString *)identifier labelsAndValues:(id)first,...
{
	NSMutableArray *array=[[NSMutableArray alloc] init];
	XeePropertyItem *item=[[self alloc] initWithLabel:itemlabel value:array identifier:identifier heading:nil position:0];

	va_list va;
	va_start(va,first);
	for(;;)
	{
		NSString *label=first?first:va_arg(va,NSString *);
		id value=va_arg(va,id);

		if(!label||!value) break;

		[array addObject:[self itemWithLabel:label value:value]];

		first=nil;
	}
	va_end(va);

	return item;
}

+(NSArray *)itemsWithLabel:(NSString *)itemlabel valueArray:(NSArray *)values
{
	NSInteger count=[values count];
	if(!values||count==0) return nil;

	XeePropertyItem *heading=[self itemWithLabel:itemlabel value:[values objectAtIndex:0]];
	NSMutableArray *items=[NSMutableArray arrayWithObject:heading];

	for(NSInteger i=1;i<count;i++) [items addObject:[self itemWithLabel:@"" value:[values objectAtIndex:i] heading:heading position:i]];

	return items;
}

+(NSArray *)itemsWithLabel:(NSString *)itemlabel values:(id)first,...
{
	if(!first) return nil;

	XeePropertyItem *heading=[self itemWithLabel:itemlabel value:first];
	NSMutableArray *items=[NSMutableArray arrayWithObject:heading];

	va_list va;
	va_start(va,first);

	id value;
	int pos=1;
	while((value=va_arg(va,id))) [items addObject:[self itemWithLabel:@"" value:value heading:heading position:pos++]];

	va_end(va);

	return items;
}

+(NSArray *)itemsWithLabel:(NSString *)itemlabel textValue:(NSString *)text
{
	NSMutableArray *array=[NSMutableArray arrayWithArray:[text componentsSeparatedByString:@"\n"]];
	while([array lastObject]&&[[array lastObject] length]==0) [array removeLastObject];
	return [self itemsWithLabel:itemlabel valueArray:array];
}



-(id)initWithLabel:(NSString *)itemlabel value:(id)itemvalue identifier:(NSString *)identifier heading:(XeePropertyItem *)headingitem position:(int)position
{
	if(self=[super init])
	{
		if(itemlabel&&[itemlabel length])
		{
			if([itemvalue isKindOfClass:[NSArray class]]) label=[itemlabel copy];
			else label=[itemlabel stringByAppendingString:@":"];
		}
		else label=@"";
		value=itemvalue;
		ident=[identifier copy];

		heading=headingitem;
		pos=position;
	}
	return self;
}

-(BOOL)isSubSection { return [value isKindOfClass:[NSArray class]]; }

-(BOOL)isEqual:(XeePropertyItem *)other
{
	return [label caseInsensitiveCompare:[other label]]==NSOrderedSame&&[value isEqual:[other value]];
}

-(NSComparisonResult)compare:(XeePropertyItem *)other
{
	XeePropertyItem *otherheading=[other heading];
	if(heading)
	{
		if(heading==otherheading)
		{
			if(pos>[other position]) return NSOrderedDescending;
			else return NSOrderedAscending;
		}
		else if(otherheading) return [heading compare:otherheading];
		else return [heading compare:other];
	}
	else if(otherheading) return [self compare:otherheading];

	return [label caseInsensitiveCompare:[other label]];
}

-(NSString *)description
{
	return [NSString stringWithFormat:@"%@ %@",label,value];
}

@end
