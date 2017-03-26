#import <Cocoa/Cocoa.h>

@class XeePropertyItem, XeeController;

@interface XeePropertiesController
	: NSObject <NSOutlineViewDataSource, NSOutlineViewDelegate> {
	IBOutlet NSPanel *infopanel;
	IBOutlet NSOutlineView *outlineview;
	NSArray *dataarray;

	NSDictionary *sectionattributes, *labelattributes;
}

- (void)awakeFromNib;

- (void)toggleVisibility;
- (BOOL)closeIfOpen;
- (void)setFullscreenMode:(BOOL)fullscreen;

- (void)frontImageDidChange:(NSNotification *)notification;
- (IBAction)doubleClick:(id)sender;

- (void)restoreCollapsedStatusForArray:(NSArray *)array;

@end

@interface XeePropertyOutlineView : NSOutlineView {
	NSColor *top_normal, *bottom_normal;
	NSDictionary *attrs_normal;
	NSColor *top_selected, *bottom_selected;
	NSDictionary *attrs_selected;
}

- (void)drawRow:(int)row clipRect:(NSRect)clip;
- (NSRect)frameOfCellAtColumn:(int)column row:(int)row;

- (IBAction)copy:(id)sender;

@end
