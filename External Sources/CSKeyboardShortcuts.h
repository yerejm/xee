#import <Cocoa/Cocoa.h>

#import "KFTypeSelectTableView.h"



#define CSCmd NSCommandKeyMask
#define CSAlt NSAlternateKeyMask
#define CSCtrl NSControlKeyMask
#define CSShift NSShiftKeyMask



@class CSKeyStroke,CSAction;



@interface CSKeyboardShortcuts:NSObject
{
	NSArray<CSAction*> *actions;
}

+(NSArray<CSAction*> *)parseMenu:(NSMenu *)menu;
+(NSArray<CSAction*> *)parseMenu:(NSMenu *)menu namespace:(NSMutableSet<NSString*> *)aNamespace;

@property (class, readonly, retain) CSKeyboardShortcuts *defaultShortcuts;
+(void)installWindowClass;

-(instancetype)init;

-(NSArray<CSAction*> *)actions;

-(void)addActions:(NSArray<CSAction*> *)actions;
-(void)addActionsFromMenu:(NSMenu *)mainmenu;
-(void)addShortcuts:(NSDictionary<NSString*,NSArray<CSAction*>*> *)shortcuts;

-(void)resetToDefaults;

-(BOOL)handleKeyEvent:(NSEvent *)event;
-(CSAction *)actionForEvent:(NSEvent *)event;
-(CSAction *)actionForEvent:(NSEvent *)event ignoringModifiers:(NSEventModifierFlags)ignoredmods;
-(CSKeyStroke *)findKeyStrokeForEvent:(NSEvent *)event index:(int *)index;

@end



@interface CSAction:NSObject
{
	NSString *title,*identifier;
	SEL sel;
	id target;
	NSMenuItem *item;
	NSImage *fullimage;
	int spacing;

	NSMutableArray *shortcuts,*defshortcuts;
}

+(CSAction *)actionWithTitle:(NSString *)acttitle selector:(SEL)selector;
+(CSAction *)actionWithTitle:(NSString *)acttitle identifier:(NSString *)ident selector:(SEL)selector;
+(CSAction *)actionWithTitle:(NSString *)acttitle identifier:(NSString *)ident selector:(SEL)selector defaultShortcut:(CSKeyStroke *)defshortcut;
+(CSAction *)actionWithTitle:(NSString *)acttitle identifier:(NSString *)ident;
+(CSAction *)actionFromMenuItem:(NSMenuItem *)item namespace:(NSMutableSet *)namespace;

-(id)initWithTitle:(NSString *)acttitle identifier:(NSString *)ident selector:(SEL)selector target:(id)acttarget defaultShortcut:(CSKeyStroke *)defshortcut;
-(id)initWithMenuItem:(NSMenuItem *)menuitem namespace:(NSMutableSet *)namespace;

@property (readonly) NSString *title;
@property (readonly) NSString *identifier;
-(SEL)selector;
@property (readonly, getter=isMenuItem) BOOL menuItem;

-(void)setDefaultShortcuts:(NSArray *)shortcutarray;
-(void)addDefaultShortcut:(CSKeyStroke *)shortcut;
-(void)addDefaultShortcuts:(NSArray *)shortcutarray;

-(void)setShortcuts:(NSArray *)shortcutarray;
-(NSArray *)shortcuts;

-(void)resetToDefaults;
-(void)loadCustomizations;
-(void)updateMenuItem;

-(BOOL)perform:(NSEvent *)event;

-(NSImage *)shortcutsImage;
-(void)clearImage;

-(NSSize)imageSizeWithDropSize:(NSSize)dropsize;
-(void)drawAtPoint:(NSPoint)point selected:(CSKeyStroke *)selected dropBefore:(CSKeyStroke *)dropbefore dropSize:(NSSize)dropsize;

-(CSKeyStroke *)findKeyAtPoint:(NSPoint)point offset:(NSPoint)offset;
-(NSPoint)findLocationOfKey:(CSKeyStroke *)searchkey offset:(NSPoint)offset;
-(CSKeyStroke *)findKeyAfterDropPoint:(NSPoint)point offset:(NSPoint)offset;

-(NSComparisonResult)compare:(CSAction *)other;

@end



@interface CSKeyStroke:NSObject
{
	NSString *chr;
	NSEventModifierFlags mod;
	NSImage *img;
}

+(CSKeyStroke *)keyForCharacter:(NSString *)character modifiers:(NSEventModifierFlags)modifiers;
+(CSKeyStroke *)keyForCharCode:(unichar)character modifiers:(NSEventModifierFlags)modifiers;
+(CSKeyStroke *)keyFromMenuItem:(NSMenuItem *)item;
+(CSKeyStroke *)keyFromEvent:(NSEvent *)event;
+(CSKeyStroke *)keyFromDictionary:(NSDictionary *)dict;

+(NSArray<CSKeyStroke *> *)keysFromDictionaries:(NSArray<NSDictionary<NSString*,id>*> *)dicts;
+(NSArray<NSDictionary<NSString*,id>*> *)dictionariesFromKeys:(NSArray<CSKeyStroke *> *)keys;

-(id)initWithCharacter:(NSString *)character modifiers:(NSEventModifierFlags)modifiers;
-(void)dealloc;

@property (readonly, copy) NSString *character;
@property (readonly) NSEventModifierFlags modifiers;
-(NSDictionary<NSString*,id> *)dictionary;

-(NSImage *)image;

-(BOOL)matchesEvent:(NSEvent *)event ignoringModifiers:(NSEventModifierFlags)ignoredmods;

-(NSString *)description;
-(NSString *)descriptionOfModifiers;
-(NSString *)descriptionOfCharacter;

@end





@interface CSKeyboardList:KFTypeSelectTableView <NSTableViewDataSource, NSDraggingSource>
{
	CSKeyStroke *selected;
	CSAction *dropaction;
	CSKeyStroke *dropbefore;
	NSSize dropsize;

	IBOutlet CSKeyboardShortcuts *keyboardShortcuts;
	IBOutlet NSTextField *infoTextField;
	IBOutlet NSControl *addButton;
	IBOutlet NSControl *removeButton;
	IBOutlet NSControl *resetButton;
}

-(id)initWithCoder:(NSCoder *)decoder;

-(void)awakeFromNib;

-(void)mouseDown:(NSEvent *)event;

-(CSAction *)getActionForLocation:(NSPoint)point hasFrame:(NSRect *)frame;

-(void)updateButtons;

-(void)setKeyboardShortcuts:(CSKeyboardShortcuts *)shortcuts;
-(CSKeyboardShortcuts *)keybardShortcuts;

-(CSAction *)getSelectedAction;

-(IBAction)addShortcut:(id)sender;
-(IBAction)removeShortcut:(id)sender;
-(IBAction)resetToDefaults:(id)sender;
-(IBAction)resetAll:(id)sender;

@end







@interface CSKeyListenerWindow:NSWindow
{
}

+(void)install;

-(BOOL)performKeyEquivalent:(NSEvent *)event;

@end



@interface NSEvent (CSKeyboardShortcutsAdditions)

+(NSString *)remapCharacters:(NSString *)characters;

-(NSString *)charactersIgnoringAllModifiers;
-(NSString *)remappedCharacters;
-(NSString *)remappedCharactersIgnoringAllModifiers;

@end
