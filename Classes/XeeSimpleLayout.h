#import <Cocoa/Cocoa.h>



@class XeeSLControl,XeeSLGroup,XeeSLPopUp,XeeSLSwitch,XeeSLSlider,XeeSLPages;

@protocol XeeSimpleLayoutDelegate;

@interface XeeSimpleLayout:NSView
{
	XeeSLControl *control;
	id<XeeSimpleLayoutDelegate> delegate;
}

-(id)initWithControl:(XeeSLControl *)content;
-(BOOL)isFlipped;

-(void)layout;
-(void)requestLayout;

@property (retain) id<XeeSimpleLayoutDelegate> delegate;

@end

@protocol XeeSimpleLayoutDelegate <NSObject>

-(void)xeeSLUpdated:(XeeSimpleLayout *)alsoview;

@end


@interface XeeSLControl:NSObject
{
	NSTextField *titlefield;
	XeeSimpleLayout *parent;
	id delegate;
}

-(id)initWithTitle:(NSString *)title;
-(void)dealloc;

-(int)height;
-(int)topSpacing;
-(int)bottomSpacing;
-(int)contentWidth;
-(int)titleWidth;

-(void)addElementsToSuperview:(XeeSimpleLayout *)superview;
-(void)layoutContent:(NSRect)contentrect title:(NSRect)titlerect;
-(void)setHidden:(BOOL)hidden;

@property (retain) id delegate;

@end



@interface XeeSLGroup:XeeSLControl
{
	NSArray *controls;
}

-(id)initWithControls:(NSArray *)controlarray;
-(void)dealloc;

-(int)height;
-(int)topSpacing;
-(int)bottomSpacing;
-(int)contentWidth;
-(int)titleWidth;

-(void)addElementsToSuperview:(XeeSimpleLayout *)superview;
-(void)layoutContent:(NSRect)contentrect title:(NSRect)titlerect;
-(void)setHidden:(BOOL)hidden;

+(XeeSLGroup *)groupWithControls:(XeeSLControl *)control,... NS_REQUIRES_NIL_TERMINATION;

@end



@interface XeeSLPopUp:XeeSLControl
{
	NSPopUpButton *popup;
	int maxwidth;
}

-(instancetype)initWithTitle:(NSString *)title contents:(NSArray *)contents defaultValue:(int)def;

-(int)height;
-(int)topSpacing;
-(int)bottomSpacing;
-(int)contentWidth;

-(void)addElementsToSuperview:(XeeSimpleLayout *)superview;
-(void)layoutContent:(NSRect)contentrect title:(NSRect)titlerect;
-(void)setHidden:(BOOL)hidden;

-(NSInteger)value;

+(XeeSLPopUp *)popUpWithTitle:(NSString *)title defaultValue:(int)def contents:(NSString *)entry,... NS_REQUIRES_NIL_TERMINATION;

@end



@interface XeeSLSwitch:XeeSLControl
{
	NSButton *check;
}

-(id)initWithTitle:(NSString *)title label:(NSString *)label defaultValue:(BOOL)def;

-(int)height;
-(int)topSpacing;
-(int)bottomSpacing;
-(int)contentWidth;

-(void)addElementsToSuperview:(XeeSimpleLayout *)superview;
-(void)layoutContent:(NSRect)contentrect title:(NSRect)titlerect;
-(void)setHidden:(BOOL)hidden;

-(BOOL)value;

+(XeeSLSwitch *)switchWithTitle:(NSString *)title label:(NSString *)label defaultValue:(BOOL)def;

@end



@interface XeeSLSlider:XeeSLControl
{
	NSSlider *slider;
	NSTextField *minfield,*maxfield;
}

-(id)initWithTitle:(NSString *)title minLabel:(NSString *)minlabel maxLabel:(NSString *)maxlabel min:(CGFloat)minval max:(CGFloat)maxval defaultValue:(CGFloat)def;

-(int)height;
-(int)topSpacing;
-(int)bottomSpacing;
-(int)contentWidth;

-(void)addElementsToSuperview:(XeeSimpleLayout *)superview;
-(void)layoutContent:(NSRect)contentrect title:(NSRect)titlerect;
-(void)setHidden:(BOOL)hidden;

@property (readonly) CGFloat value;

+(XeeSLSlider *)sliderWithTitle:(NSString *)title minLabel:(NSString *)minlabel maxLabel:(NSString *)maxlabel min:(CGFloat)minval max:(CGFloat)maxval defaultValue:(CGFloat)def;

@end



@interface XeeSLPages:XeeSLPopUp
{
	NSArray *pages;
}

-(instancetype)initWithTitle:(NSString *)title pages:(NSArray *)pagearray names:(NSArray *)namearray defaultValue:(int)def;

-(int)height;
-(int)bottomSpacing;
-(int)contentWidth;
-(int)titleWidth;

-(void)addElementsToSuperview:(XeeSimpleLayout *)superview;
-(void)layoutContent:(NSRect)contentrect title:(NSRect)titlerect;
-(void)setHidden:(BOOL)hidden;

//+(XeeSLPages *)pagesWithTitle:(NSString *)title pagesAndNames:(id)page,... defaultValue:(int)def;

@end
