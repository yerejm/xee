#import <Cocoa/Cocoa.h>

@class XeeImage,XeeController,XeeSLPages,XeeSimpleLayout;
@class XeeImageSaver;

@interface XeeSavePanel:NSSavePanel
{
	XeeImage *image;
	XeeController *controller;
	NSArray<XeeImageSaver*> *savers;
	XeeSLPages *formats;
	XeeSimpleLayout *view;

	NSTextView *textview;
	NSTextField *textfield;

	BOOL wasanimating;
}

+(void)runSavePanelForImage:(XeeImage *)image controller:(XeeController *)controller;

-(instancetype)initWithImage:(XeeImage *)img controller:(XeeController *)cont;

-(void)savePanelDidEnd:(NSSavePanel *)sheet returnCode:(NSInteger)res contextInfo:(void *)info;
-(void)xeeSLUpdated:(XeeSimpleLayout *)alsoview;

-(NSString *)updateExtension:(NSString *)filename;
-(NSString *)filenameFieldContents;
-(void)setFilenameFieldContents:(NSString *)filename;
-(void)selectNamePart;

@end
