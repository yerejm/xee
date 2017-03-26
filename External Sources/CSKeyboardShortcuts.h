#import <Cocoa/Cocoa.h>

#import "KFTypeSelectTableView.h"

#define CSCmd NSEventModifierFlagCommand
#define CSAlt NSEventModifierFlagOption
#define CSCtrl NSEventModifierFlagControl
#define CSShift NSEventModifierFlagShift

@class CSKeyStroke, CSAction;

NS_ASSUME_NONNULL_BEGIN

@interface CSKeyboardShortcuts : NSObject {
	NSArray<CSAction *> *actions;
}

+ (NSArray<CSAction *> *)parseMenu:(NSMenu *)menu;
+ (NSArray<CSAction *> *)parseMenu:(NSMenu *)menu
						 namespace:(NSMutableSet<NSString *> *)aNamespace;

@property (class, readonly, strong, nullable) CSKeyboardShortcuts *defaultShortcuts;
+ (void)installWindowClass;

- (instancetype)init;

@property (readonly, copy) NSArray<CSAction *> *actions;

- (void)addActions:(NSArray<CSAction *> *)actions;
- (void)addActionsFromMenu:(NSMenu *)mainmenu;
- (void)addShortcuts:
	(NSDictionary<NSString *, NSArray<CSAction *> *> *)shortcuts;

- (void)resetToDefaults;

- (BOOL)handleKeyEvent:(NSEvent *)event;
- (nullable CSAction *)actionForEvent:(NSEvent *)event;
- (nullable CSAction *)actionForEvent:(NSEvent *)event
					ignoringModifiers:(NSEventModifierFlags)ignoredmods;
- (nullable CSKeyStroke *)findKeyStrokeForEvent:(NSEvent *)event
										  index:(NSInteger *)index;

@end

@interface CSAction : NSObject {
	NSString *title, *identifier;
	SEL sel;
	id target;
	NSMenuItem *item;
	NSImage *fullimage;
	int spacing;

	NSMutableArray *shortcuts, *defshortcuts;
}

+ (CSAction *)actionWithTitle:(NSString *)acttitle selector:(SEL)selector;
+ (CSAction *)actionWithTitle:(NSString *)acttitle
				   identifier:(nullable NSString *)ident
					 selector:(SEL)selector;
+ (CSAction *)actionWithTitle:(NSString *)acttitle
				   identifier:(nullable NSString *)ident
					 selector:(SEL)selector
			  defaultShortcut:(CSKeyStroke *)defshortcut;
+ (CSAction *)actionWithTitle:(NSString *)acttitle identifier:(NSString *)ident;
+ (CSAction *)actionFromMenuItem:(NSMenuItem *)item
					   namespace:(NSMutableSet<NSString *> *)aNamespace
	NS_SWIFT_UNAVAILABLE("use CSAction(menuItem:namespace:) instead");

- (instancetype)initWithTitle:(NSString *)acttitle
				   identifier:(nullable NSString *)ident
					 selector:(nullable SEL)selector
					   target:(nullable id)acttarget
			  defaultShortcut:(nullable CSKeyStroke *)defshortcut;
- (instancetype)initWithMenuItem:(NSMenuItem *)menuitem
					   namespace:(NSMutableSet<NSString *> *)aNamespace;

@property (readonly, copy) NSString *title;
@property (readonly, copy) NSString *identifier;
@property (readonly, nullable) SEL selector;
@property (readonly, getter=isMenuItem) BOOL menuItem;

- (void)setDefaultShortcuts:(NSArray<CSKeyStroke *> *)shortcutarray;
- (void)addDefaultShortcut:(CSKeyStroke *)shortcut;
- (void)addDefaultShortcuts:(NSArray<CSKeyStroke *> *)shortcutarray;

@property (copy, null_resettable) NSArray<CSKeyStroke *> *shortcuts;

- (void)resetToDefaults;
- (void)loadCustomizations;
- (void)updateMenuItem;

- (BOOL)perform:(NSEvent *)event;

@property (readonly, retain, nullable) NSImage *shortcutsImage;
- (void)clearImage;

- (NSSize)imageSizeWithDropSize:(NSSize)dropsize;
- (void)drawAtPoint:(NSPoint)point
		   selected:(nullable CSKeyStroke *)selected
		 dropBefore:(nullable CSKeyStroke *)dropbefore
		   dropSize:(NSSize)dropsize;

- (nullable CSKeyStroke *)findKeyAtPoint:(NSPoint)point offset:(NSPoint)offset;
- (NSPoint)findLocationOfKey:(CSKeyStroke *)searchkey offset:(NSPoint)offset;
- (nullable CSKeyStroke *)findKeyAfterDropPoint:(NSPoint)point
										 offset:(NSPoint)offset;

- (NSComparisonResult)compare:(CSAction *)other;

@end

@interface CSKeyStroke : NSObject {
	NSString *chr;
	NSEventModifierFlags mod;
	NSImage *img;
}

+ (CSKeyStroke *)keyForCharacter:(NSString *)character
					   modifiers:(NSEventModifierFlags)modifiers;
+ (CSKeyStroke *)keyForCharCode:(unichar)character
					  modifiers:(NSEventModifierFlags)modifiers;
+ (nullable CSKeyStroke *)keyFromMenuItem:(NSMenuItem *)item;
+ (CSKeyStroke *)keyFromEvent:(NSEvent *)event;
+ (CSKeyStroke *)keyFromDictionary:(NSDictionary *)dict;

+ (NSArray<CSKeyStroke *> *)keysFromDictionaries:
	(NSArray<NSDictionary<NSString *, id> *> *)dicts;
+ (NSArray<NSDictionary<NSString *, id> *> *)dictionariesFromKeys:
	(NSArray<CSKeyStroke *> *)keys;

- (instancetype)initWithCharacter:(NSString *)character
						modifiers:(NSEventModifierFlags)modifiers;

@property (readonly, copy) NSString *character;
@property (readonly) NSEventModifierFlags modifiers;
@property (readonly) NSDictionary<NSString *, id> *dictionary;

@property (readonly, retain) NSImage *image;

- (BOOL)matchesEvent:(NSEvent *)event
	ignoringModifiers:(NSEventModifierFlags)ignoredmods;

@property (readonly, copy) NSString *description;
@property (readonly, copy) NSString *descriptionOfModifiers;
@property (readonly, copy) NSString *descriptionOfCharacter;

@end

@interface CSKeyboardList
	: KFTypeSelectTableView <NSTableViewDataSource, NSTableViewDelegate,
							 NSDraggingSource, NSDraggingDestination> {
	__unsafe_unretained CSKeyStroke *selected;
	__unsafe_unretained CSAction *dropaction;
	__unsafe_unretained CSKeyStroke *dropbefore;
	NSSize dropsize;

	IBOutlet NSTextField *infoTextField;
	IBOutlet NSControl *addButton;
	IBOutlet NSControl *removeButton;
	IBOutlet NSControl *resetButton;
}

- (void)awakeFromNib;

- (void)mouseDown:(NSEvent *)event;

- (nullable CSAction *)getActionForLocation:(NSPoint)point
								   hasFrame:(nullable NSRect *)frame;

- (void)updateButtons;

@property (strong, nonatomic) IBOutlet CSKeyboardShortcuts *keyboardShortcuts;

- (CSAction *)getSelectedAction;

- (IBAction)addShortcut:(nullable id)sender;
- (IBAction)removeShortcut:(nullable id)sender;
- (IBAction)resetToDefaults:(nullable id)sender;
- (IBAction)resetAll:(nullable id)sender;

@end

@interface CSKeyListenerWindow : NSWindow

+ (void)install;

- (BOOL)performKeyEquivalent:(NSEvent *)event;

@end

@interface NSEvent (CSKeyboardShortcutsAdditions)

+ (NSString *)remapCharacters:(NSString *)characters;

- (NSString *)charactersIgnoringAllModifiers;
- (NSString *)remappedCharacters;
- (NSString *)remappedCharactersIgnoringAllModifiers;

@end

NS_ASSUME_NONNULL_END
