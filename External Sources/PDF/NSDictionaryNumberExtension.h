#import <Foundation/Foundation.h>

@interface NSDictionary (NumberExtension)

- (int)intValueForKey:(NSString *)key default:(int)def NS_SWIFT_UNAVAILABLE("Better methods/casting can be made in Swift");
- (unsigned int)unsignedIntValueForKey:(NSString *)key
							   default:(unsigned int)def NS_SWIFT_UNAVAILABLE("Better methods/casting can be made in Swift");
- (BOOL)boolValueForKey:(NSString *)key default:(BOOL)def NS_SWIFT_UNAVAILABLE("Better methods/casting can be made in Swift");
- (float)floatValueForKey:(NSString *)key default:(float)def NS_SWIFT_UNAVAILABLE("Better methods/casting can be made in Swift");
- (double)doubleValueForKey:(NSString *)key default:(double)def NS_SWIFT_UNAVAILABLE("Better methods/casting can be made in Swift");

- (NSString *)stringForKey:(NSString *)key default:(NSString *)def NS_SWIFT_UNAVAILABLE("Better methods/casting can be made in Swift");
- (NSArray *)arrayForKey:(NSString *)key NS_SWIFT_UNAVAILABLE("Better methods/casting can be made in Swift");

@end
