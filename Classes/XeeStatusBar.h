#import <Cocoa/Cocoa.h>



@interface XeeStatusBar:NSView
{
	NSMutableArray *cells;
	CGShadingRef shading;
}

-(instancetype)initWithFrame:(NSRect)frame;

-(void)drawRect:(NSRect)rect;

-(void)addCell:(NSCell *)cell;
-(void)removeAllCells;

-(void)addEntry:(NSString *)title;
-(void)addEntry:(NSString *)title imageNamed:(NSString *)imagename;
-(void)addEntry:(NSString *)title image:(NSImage *)image;

@end



@interface XeeStatusCell:NSCell
{
	int spacing;
	NSString *titlestring;
}

-(instancetype)initWithImage:(NSImage *)image title:(NSString *)title;

@property (copy) NSString *title;

-(NSSize)cellSize;
-(void)drawInteriorWithFrame:(NSRect)frame inView:(NSView *)view;

+(XeeStatusCell *)statusWithImageNamed:(NSString *)name title:(NSString *)title;

@end
