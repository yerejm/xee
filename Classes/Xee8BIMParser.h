#import <Cocoa/Cocoa.h>
#import "XeeParser.h"

#import "XeeTypes.h"
#import <XADMaster/CSHandle.h>
@class XeePropertyItem;

@interface Xee8BIMParser : NSObject {
	NSMutableArray *props;
	NSArray *xmpprops, *iptcprops, *exifprops;

	NSInteger numcolours, trans;
	BOOL hasmerged, copyrighted, watermarked, untagged;
}

- (instancetype)initWithHandle:(CSHandle *)handle;

@property (readonly) BOOL hasMergedImage;
@property (readonly) NSInteger numberOfIndexedColours;
@property (readonly) NSInteger indexOfTransparentColour;

- (NSArray<XeePropertyItem *> *)propertyArrayWithPhotoshopFirst:(BOOL)psfirst;
@end
