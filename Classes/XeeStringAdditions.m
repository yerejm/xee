#import "XeeStringAdditions.h"

@implementation NSString (XeeStringAdditions)

-(NSString *)stringByMappingColonToSlash
{
	NSMutableString *str=[NSMutableString stringWithString:self];
	[str replaceOccurrencesOfString:@":" withString:@"/" options:0 range:NSMakeRange(0,[self length])];
	return [str copy];
}

-(NSString *)stringByMappingSlashToColon
{
	NSMutableString *str=[NSMutableString stringWithString:self];
	[str replaceOccurrencesOfString:@"/" withString:@":" options:0 range:NSMakeRange(0,[self length])];
	return [str copy];
}

@end

NSString *XeeDescribeDate(NSDate *date)
{
	return [date descriptionWithCalendarFormat:@"%Y-%m-%d %H:%M" timeZone:nil locale:nil];
}

NSString *XeeDescribeSize(uint64_t size)
{
	return [NSByteCountFormatter stringFromByteCount:size countStyle:NSByteCountFormatterCountStyleFile];
}
