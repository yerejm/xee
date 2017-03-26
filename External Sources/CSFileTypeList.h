#import <Cocoa/Cocoa.h>

@interface CSFileTypeList : NSTableView

- (instancetype)initWithCoder:(NSCoder *)coder;
- (instancetype)initWithFrame:(NSRect)frame;

- (IBAction)selectAll:(id)sender;
- (IBAction)deselectAll:(id)sender;

@end

/*
	Columns:
	enabled (checkbox)
	description (string)
	extensions (string)
	[type] (string)
*/

@interface CSFileTypeListSource : NSObject <NSTableViewDataSource, NSTableViewDelegate> {
	NSArray *filetypes;
}

- (instancetype)init;
@property (readonly, copy) NSArray<NSDictionary<NSString*,id>*> *readFileTypes;

- (void)claimAllTypes;
- (void)surrenderAllTypes;
- (void)claimType:(NSString *)type;
- (void)surrenderType:(NSString *)type;
- (void)setHandler:(NSString *)handler forType:(NSString *)type;
- (void)removeHandlerForType:(NSString *)type;

@end
