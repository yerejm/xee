#import <Cocoa/Cocoa.h>

@interface CSFileTypeList:NSTableView

-(id)initWithCoder:(NSCoder *)coder;
-(id)initWithFrame:(NSRect)frame;

-(IBAction)selectAll:(id)sender;
-(IBAction)deselectAll:(id)sender;

@end

/*
	Columns:
	enabled (checkbox)
	description (string)
	extensions (string)
	[type] (string)
*/

@interface CSFileTypeListSource:NSObject <NSTableViewDataSource, NSTableViewDelegate>
{
	NSArray *filetypes;
}

-(id)init;
-(NSArray *)readFileTypes;

-(void)claimAllTypes;
-(void)surrenderAllTypes;
-(void)claimType:(NSString *)type;
-(void)surrenderType:(NSString *)type;
-(void)setHandler:(NSString *)handler forType:(NSString *)type;
-(void)removeHandlerForType:(NSString *)type;

@end
