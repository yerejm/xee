#import <Cocoa/Cocoa.h>

#import "KFTypeSelectTableView.h"

@class XeeController;

@interface XeeDestinationView:KFTypeSelectTableView <NSTableViewDataSource>
{
	NSMutableArray *destinations;
	NSInteger droprow,dropnum;
	BOOL movemode,surpressshortcut;

	IBOutlet XeeController *controller;
}

-(void)dealloc;
-(void)awakeFromNib;

-(void)drawRow:(NSInteger)row clipRect:(NSRect)clipRect;

-(void)keyDown:(NSEvent *)event;
-(NSMenu*)menuForEvent:(NSEvent *)event;
-(void)mouseDown:(NSEvent *)event;

-(NSInteger)rowForDropPoint:(NSPoint)point;
-(void)setDropRow:(NSInteger)row num:(NSInteger)num;
-(void)setDropRow:(NSInteger)row;

-(void)updateData:(id)notification;

-(IBAction)switchMode:(id)sender;
-(IBAction)openInXee:(id)sender;
-(IBAction)openInFinder:(id)sender;
-(IBAction)removeFromList:(id)sender;

-(NSInteger)indexForRow:(NSInteger)row;
-(NSString *)pathForRow:(NSInteger)row;
-(NSString *)shortcutForRow:(NSInteger)row;

+(void)updateTables;
+(void)suggestInsertion:(NSString *)directory;
+(void)addDestinations:(NSArray<NSString*> *)directories index:(NSInteger)index;
+(NSInteger)findDestination:(NSString *)directory;
+(void)loadArray;
+(void)saveArray;
+(NSMutableArray *)defaultArray;

@end
