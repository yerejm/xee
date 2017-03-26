//
//  XeeParser.h
//  Xee
//
//  Created by C.W. Betts on 3/14/17.
//
//

#import <Foundation/Foundation.h>

@class XeePropertyItem;

@protocol XeeParser <NSObject>
- (NSArray<XeePropertyItem *> *)propertyArray;

@end
