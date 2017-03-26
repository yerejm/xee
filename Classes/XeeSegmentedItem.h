#import <Cocoa/Cocoa.h>

@interface XeeSegmentedItem : NSToolbarItem {
	NSSegmentedControl *control;
	NSMenu *menu;
	SEL *actions;
}

+ (instancetype)itemWithIdentifier:(NSString *)identifier
							 label:(NSString *)label
					  paletteLabel:(NSString *)pallabel
						  segments:(int)segments;

- (instancetype)initWithItemIdentifier:(NSString *)identifier
								 label:(NSString *)label
						  paletteLabel:(NSString *)pallabel
							  segments:(int)segments;

- (void)validate;

- (void)setSegment:(int)segment
			 label:(NSString *)label
			 image:(NSImage *)image
		 longLabel:(NSString *)longlabel
			 width:(int)width
			action:(SEL)action;
- (void)setSegment:(int)segment
			 label:(NSString *)label
		 longLabel:(NSString *)longlabel
			action:(SEL)action;
- (void)setSegment:(int)segment
		 imageName:(NSString *)imagename
		 longLabel:(NSString *)longlabel
			action:(SEL)action;
- (void)setupView;

- (void)clicked:(id)sender;

@end

@interface XeeToolItem : XeeSegmentedItem {
	SEL sel;
	id target;
}

+ (instancetype)itemWithIdentifier:(NSString *)identifier
							 label:(NSString *)label
					  paletteLabel:(NSString *)pallabel
						 imageName:(NSString *)imagename
						 longLabel:(NSString *)longlabel
							action:(SEL)action
					activeSelector:(SEL)activeselector
							target:(id)activetarget;

- (instancetype)initWithItemIdentifier:(NSString *)identifier
								 label:(NSString *)label
						  paletteLabel:(NSString *)pallabel
							 imageName:(NSString *)imagename
							 longLabel:(NSString *)longlabel
								action:(SEL)action
						activeSelector:(SEL)activeselector
								target:(id)activetarget;
- (void)validate;

@end
