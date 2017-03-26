#import "CSKeyboardShortcuts.h"

#include <Carbon/Carbon.h>

// CSKeyboardShortcuts

static CSKeyboardShortcuts *defaultshortcuts = nil;

@implementation CSKeyboardShortcuts
@synthesize actions;

+ (NSArray *)parseMenu:(NSMenu *)menu
{
	return [self parseMenu:menu namespace:[NSMutableSet set]];
}

+ (NSArray *)parseMenu:(NSMenu *)menu namespace:(NSMutableSet *)namespace
{
	NSMutableArray *array = [[NSMutableArray alloc] init];

	NSInteger count = [menu numberOfItems];
	for (NSInteger i = 0; i < count; i++) {
		NSMenuItem *item = [menu itemAtIndex:i];
		NSMenu *submenu = [item submenu];
		SEL sel = [item action];

		if (submenu) {
			[array addObjectsFromArray:[self parseMenu:submenu namespace:namespace]];
		} else if (sel) {
			[array addObject:[CSAction actionFromMenuItem:item namespace:namespace]];
		}
	}

	return [array copy];
}

+ (CSKeyboardShortcuts *)defaultShortcuts
{
	return defaultshortcuts;
}

+ (void)installWindowClass
{
	[CSKeyListenerWindow install];
}

- (id)init
{
	if (self = [super init]) {
		actions = [[NSArray alloc] init];
		if (!defaultshortcuts) {
			defaultshortcuts = self;
		}
	}
	return self;
}

- (void)addActions:(NSArray *)moreactions
{
	actions = [[actions arrayByAddingObjectsFromArray:moreactions] sortedArrayUsingSelector:@selector(compare:)];
}

- (void)addActionsFromMenu:(NSMenu *)menu
{
	[self addActions:[CSKeyboardShortcuts parseMenu:menu]];
}

- (void)addShortcuts:(NSDictionary *)shortcuts
{
	for (CSAction *action in actions) {
		NSArray *defkeys = [shortcuts objectForKey:[action identifier]];
		if (defkeys) {
			[action addDefaultShortcuts:defkeys];
		}
	}
}

- (void)resetToDefaults
{
	for (CSAction *action in actions) {
		[action resetToDefaults];
	}
}

- (BOOL)handleKeyEvent:(NSEvent *)event
{
	CSAction *action = [self actionForEvent:event ignoringModifiers:0];
	if (action && [action perform:event]) {
		return YES;
	} else {
		return NO;
	}
}

- (CSAction *)actionForEvent:(NSEvent *)event
{
	return [self actionForEvent:event ignoringModifiers:0];
}

- (CSAction *)actionForEvent:(NSEvent *)event ignoringModifiers:(NSEventModifierFlags)ignoredmods
{
	for (CSAction *action in actions) {
		for (CSKeyStroke *key in action.shortcuts) {
			if ([key matchesEvent:event ignoringModifiers:ignoredmods]) {
				return action;
			}
		}
	}
	return nil;
}

- (CSKeyStroke *)findKeyStrokeForEvent:(NSEvent *)event index:(NSInteger *)index
{
	NSInteger i = 0;
	for (CSAction *action in actions) {
		for (CSKeyStroke *key in action.shortcuts) {
			if ([key matchesEvent:event ignoringModifiers:0]) {
				if (index) {
					*index = i;
				}
				return key;
			}
		}
		i++;
	}
	return nil;
}

@end

// CSAction

@implementation CSAction
@synthesize title;
@synthesize identifier;
@synthesize selector = sel;

+ (CSAction *)actionWithTitle:(NSString *)acttitle selector:(SEL)selector
{
	return [[CSAction alloc] initWithTitle:acttitle identifier:nil selector:selector target:nil defaultShortcut:nil];
}

+ (CSAction *)actionWithTitle:(NSString *)acttitle identifier:(NSString *)ident selector:(SEL)selector
{
	return [[CSAction alloc] initWithTitle:acttitle identifier:ident selector:selector target:nil defaultShortcut:nil];
}

+ (CSAction *)actionWithTitle:(NSString *)acttitle identifier:(NSString *)ident selector:(SEL)selector defaultShortcut:(CSKeyStroke *)defshortcut
{
	return [[CSAction alloc] initWithTitle:acttitle identifier:ident selector:selector target:nil defaultShortcut:defshortcut];
}

+ (CSAction *)actionWithTitle:(NSString *)acttitle identifier:(NSString *)ident
{
	return [[CSAction alloc] initWithTitle:acttitle identifier:ident selector:0 target:nil defaultShortcut:nil];
}

+ (CSAction *)actionFromMenuItem:(NSMenuItem *)item namespace:(NSMutableSet *)namespace
{
	return [[CSAction alloc] initWithMenuItem:item namespace:namespace];
}

- (id)initWithTitle:(NSString *)acttitle identifier:(NSString *)ident selector:(SEL)selector target:(id)acttarget defaultShortcut:(CSKeyStroke *)defshortcut
{
	if (self = [super init]) {
		title = [acttitle copy];
		if (ident) {
			identifier = [ident copy];
		} else {
			identifier = NSStringFromSelector(selector);
		}
		sel = selector;
		target = acttarget;

		shortcuts = nil;
		defshortcuts = [[NSMutableArray alloc] init];

		item = nil;
		fullimage = nil;

		spacing = 8;

		if (defshortcut) {
			[defshortcuts addObject:defshortcut];
		}

		[self loadCustomizations];
	}
	return self;
}

- (id)initWithMenuItem:(NSMenuItem *)menuitem namespace:(NSMutableSet *)namespace
{
	NSString *baseidentifier = NSStringFromSelector([menuitem action]);
	if ([menuitem tag]) {
		baseidentifier = [NSString stringWithFormat:@"%@%ld", baseidentifier, (long)[menuitem tag]];
	}

	NSString *uniqueidentifier = baseidentifier;

	NSInteger counter = 2;
	while ([namespace containsObject:uniqueidentifier]) {
		uniqueidentifier = [NSString stringWithFormat:@"%@(%ld)", baseidentifier, (long)counter];
		counter++;
	}

	[namespace addObject:uniqueidentifier];

	if (self = [self initWithTitle:[menuitem title]
						identifier:uniqueidentifier
						  selector:[menuitem action]
							target:[menuitem target]
				   defaultShortcut:[CSKeyStroke keyFromMenuItem:menuitem]]) {
		item = menuitem;
		[self updateMenuItem];
	}
	return self;
}

- (BOOL)isMenuItem
{
	return item ? YES : NO;
}

- (void)setDefaultShortcuts:(NSArray<CSKeyStroke *> *)shortcutarray
{
	[defshortcuts removeAllObjects];
	[defshortcuts addObjectsFromArray:shortcutarray];
	[self updateMenuItem];
	[self clearImage];
}

- (void)addDefaultShortcut:(CSKeyStroke *)shortcut
{
	[defshortcuts addObject:shortcut];
	[self updateMenuItem];
	[self clearImage];
}

- (void)addDefaultShortcuts:(NSArray<CSKeyStroke *> *)shortcutarray
{
	[defshortcuts addObjectsFromArray:shortcutarray];
	[self updateMenuItem];
	[self clearImage];
}

- (void)setShortcuts:(NSArray<CSKeyStroke *> *)shortcutarray
{
	NSString *key = [@"shortcuts." stringByAppendingString:identifier];
	if (!shortcutarray || [shortcutarray isEqual:defshortcuts]) {
		shortcuts = nil;
		[[NSUserDefaults standardUserDefaults] removeObjectForKey:key];
	} else {
		shortcuts = [shortcutarray mutableCopy];
		NSArray *dictionaries = [CSKeyStroke dictionariesFromKeys:shortcuts];
		[[NSUserDefaults standardUserDefaults] setObject:dictionaries forKey:key];
	}
	[[NSUserDefaults standardUserDefaults] removeObjectForKey:identifier]; // also remove old-style

	[self updateMenuItem];
	[self clearImage];
}

- (NSArray *)shortcuts
{
	return shortcuts ?: defshortcuts;
}

- (void)resetToDefaults
{
	[self setShortcuts:nil];
}

- (void)loadCustomizations
{
	NSArray *dictionaries = [[NSUserDefaults standardUserDefaults] arrayForKey:[@"shortcuts." stringByAppendingString:identifier]];
	if (!dictionaries) {
		dictionaries = [[NSUserDefaults standardUserDefaults] arrayForKey:identifier];
	}

	if (dictionaries) {
		shortcuts = [[CSKeyStroke keysFromDictionaries:dictionaries] mutableCopy];
		[self updateMenuItem];
		[self clearImage];
	}
}

- (void)updateMenuItem
{
	if (!item) {
		return;
	}

	NSArray *currshortcuts = [self shortcuts];

	if ([currshortcuts count]) {
		CSKeyStroke *key = [currshortcuts objectAtIndex:0];
		[item setKeyEquivalent:[key character]];
		[item setKeyEquivalentModifierMask:[key modifiers]];
	} else {
		[item setKeyEquivalent:@""];
		[item setKeyEquivalentModifierMask:0];
	}
}

- (BOOL)perform:(NSEvent *)event
{
	if (!sel) {
		return NO;
	}

	if (item) {
		[[item menu] update];
		if ([item isEnabled]) {
			NSString *keyequivalent = [item keyEquivalent];
			NSEventModifierFlags modifiermask = [item keyEquivalentModifierMask];

			item.keyEquivalent = @"\020";
			item.keyEquivalentModifierMask = CSCmd | CSShift | CSAlt | CSCtrl;

			NSEvent *keyevent = [NSEvent keyEventWithType:NSKeyDown
												 location:[event locationInWindow]
											modifierFlags:CSCmd | CSShift | CSAlt | CSCtrl
												timestamp:[event timestamp]
											 windowNumber:[event windowNumber]
												  context:[event context]
											   characters:@"\020"
							  charactersIgnoringModifiers:@"\020"
												isARepeat:[event isARepeat]
												  keyCode:0];

			BOOL res = [[item menu] performKeyEquivalent:keyevent];

			[item setKeyEquivalent:keyequivalent];
			[item setKeyEquivalentModifierMask:modifiermask];

			return res;
		} else {
			return YES; // avoid beeping
		}
	} else {
		return [[NSApplication sharedApplication] sendAction:sel to:target from:nil];
	}
}

- (NSImage *)shortcutsImage
{
	if (![[self shortcuts] count]) {
		return nil;
	}

	if (!fullimage) {
		fullimage = [[NSImage alloc] initWithSize:[self imageSizeWithDropSize:NSZeroSize]];
		[fullimage lockFocus];
		[self drawAtPoint:NSZeroPoint selected:nil dropBefore:nil dropSize:NSZeroSize];
		[fullimage unlockFocus];
	}
	return fullimage;
}

- (void)clearImage
{
	fullimage = nil;
}

- (NSSize)imageSizeWithDropSize:(NSSize)dropsize
{
	int width = 0, height = 0;

	for (CSKeyStroke *key in [self shortcuts]) {
		NSSize size = [[key image] size];
		width += size.width + spacing;
		height = MAX(size.height, height);
	}
	width -= spacing;

	if (dropsize.width) {
		width += dropsize.width + spacing;
		height = MAX(dropsize.height, height);
	}

	if (width < 0) {
		return NSZeroSize;
	} else {
		return NSMakeSize(width, height);
	}
}

- (void)drawAtPoint:(NSPoint)point selected:(CSKeyStroke *)selected dropBefore:(CSKeyStroke *)dropbefore dropSize:(NSSize)dropsize
{
	for (CSKeyStroke *key in [self shortcuts]) {
		NSSize size = [[key image] size];

		if (key == dropbefore) {
			[[NSColor colorWithCalibratedWhite:0 alpha:0.33] set];
			[NSBezierPath fillRect:NSMakeRect(point.x, point.y, dropsize.width, dropsize.height)];
			point.x += dropsize.width + spacing;
		}

		[[key image] drawAtPoint:point
						fromRect:NSZeroRect
					   operation:NSCompositeSourceOver
						fraction:1];

		if (key == selected) {
			[[NSColor colorWithCalibratedWhite:0 alpha:0.33] set];
			[NSBezierPath fillRect:NSMakeRect(point.x, point.y, size.width, size.height)];
		}

		point.x += size.width + spacing;
	}

	if (!dropbefore && dropsize.width) { // drop at end
		[[NSColor colorWithCalibratedWhite:0 alpha:0.33] set];
		[NSBezierPath fillRect:NSMakeRect(point.x, point.y, dropsize.width, dropsize.height)];
	}
}

- (CSKeyStroke *)findKeyAtPoint:(NSPoint)point offset:(NSPoint)offset
{
	NSPoint searchpoint = offset;
	for (CSKeyStroke *key in self.shortcuts) {
		NSSize size = [[key image] size];
		if (NSPointInRect(point, NSMakeRect(searchpoint.x, searchpoint.y, size.width, size.height))) {
			return key;
		}

		searchpoint.x += size.width + spacing;
	}
	return nil;
}

- (NSPoint)findLocationOfKey:(CSKeyStroke *)searchkey offset:(NSPoint)offset
{
	NSPoint searchpoint = offset;
	for (CSKeyStroke *key in self.shortcuts) {
		NSSize size = [[key image] size];
		if (key == searchkey) {
			return searchpoint;
		}

		searchpoint.x += size.width + spacing;
	}
	return NSMakePoint(0, 0);
}

- (CSKeyStroke *)findKeyAfterDropPoint:(NSPoint)point offset:(NSPoint)offset
{
	NSPoint searchpoint = offset;

	int prevdistance = point.x - searchpoint.x;
	if (prevdistance < 0) {
		prevdistance = -prevdistance;
	}

	for (CSKeyStroke *key in self.shortcuts) {
		NSSize size = [[key image] size];
		searchpoint.x += size.width + spacing;

		int distance = point.x - searchpoint.x;
		if (distance < 0) {
			distance = -distance;
		}
		if (distance >= prevdistance) {
			return key;
		}

		prevdistance = distance;
	}
	return nil;
}

- (NSString *)description
{
	return identifier;
}

- (NSComparisonResult)compare:(CSAction *)other
{
	return [title compare:[other title] options:NSNumericSearch | NSCaseInsensitiveSearch];
}

@end

// CSKeyStroke

@implementation CSKeyStroke
@synthesize modifiers = mod;
@synthesize character = chr;

+ (CSKeyStroke *)keyForCharacter:(NSString *)character modifiers:(NSEventModifierFlags)modifiers
{
	return [[CSKeyStroke alloc] initWithCharacter:character modifiers:modifiers];
}

+ (CSKeyStroke *)keyForCharCode:(unichar)character modifiers:(NSEventModifierFlags)modifiers;
{
	return [CSKeyStroke keyForCharacter:[NSString stringWithFormat:@"%C", character] modifiers:modifiers];
}

+ (CSKeyStroke *)keyFromMenuItem:(NSMenuItem *)item
{
	if ([[item keyEquivalent] length] == 0) {
		return nil;
	}
	return [CSKeyStroke keyForCharacter:[item keyEquivalent] modifiers:[item keyEquivalentModifierMask]];
}

+ (CSKeyStroke *)keyFromEvent:(NSEvent *)event
{
	NSString *character = [event remappedCharactersIgnoringAllModifiers];
	NSEventModifierFlags modifiers = [event modifierFlags];
	return [CSKeyStroke keyForCharacter:character modifiers:modifiers];
}

+ (CSKeyStroke *)keyFromDictionary:(NSDictionary *)dict
{
	NSString *character = [dict objectForKey:@"character"];
	NSEventModifierFlags modifiers = [[dict objectForKey:@"modifiers"] unsignedIntegerValue];
	return [CSKeyStroke keyForCharacter:character modifiers:modifiers];
}

+ (NSArray *)keysFromDictionaries:(NSArray *)dicts
{
	NSMutableArray *keys = [NSMutableArray arrayWithCapacity:[dicts count]];

	for (NSDictionary *dict in dicts) {
		[keys addObject:[CSKeyStroke keyFromDictionary:dict]];
	}

	return keys;
}

+ (NSArray *)dictionariesFromKeys:(NSArray *)keys
{
	NSMutableArray *dicts = [NSMutableArray arrayWithCapacity:[keys count]];

	for (CSKeyStroke *key in keys) {
		[dicts addObject:[key dictionary]];
	}

	return dicts;
}

- (id)initWithCharacter:(NSString *)character modifiers:(NSEventModifierFlags)modifiers
{
	if (self = [super init]) {
		chr = [character copy];
		mod = modifiers & (NSEventModifierFlagCommand | NSEventModifierFlagOption | NSEventModifierFlagControl | NSEventModifierFlagShift);

		img = nil;
	}
	return self;
}

- (NSDictionary *)dictionary
{
	return [NSDictionary dictionaryWithObjectsAndKeys:
							 chr, @"character",
							 @(mod), @"modifiers",
							 nil];
}

- (NSImage *)image
{
	if (!img) {
		NSString *text = [self description];
		NSImage *left = [NSImage imageNamed:@"button_left"];
		NSImage *mid = [NSImage imageNamed:@"button_mid"];
		NSImage *right = [NSImage imageNamed:@"button_right"];
		NSFont *font = [NSFont menuFontOfSize:13];
		NSDictionary *attrs = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];

		NSSize textsize = [text sizeWithAttributes:attrs];
		int textwidth = textsize.width;
		int textheight = textsize.height;

		int imgwidth = textwidth + 14 + 7;
		int imgheight = [left size].height;
		imgwidth -= imgwidth % 8;

		NSSize imgsize = NSMakeSize(imgwidth, imgheight);
		NSPoint point = NSMakePoint((imgwidth - textwidth) / 2, (imgheight - textheight) / 2 + 1);

		img = [[NSImage alloc] initWithSize:imgsize];

		[img lockFocus];

		[left drawAtPoint:NSMakePoint(0, 0)
				 fromRect:NSZeroRect
				operation:NSCompositeSourceOver
				 fraction:1];
		[right drawAtPoint:NSMakePoint(imgsize.width - [right size].width, 0)
				  fromRect:NSZeroRect
				 operation:NSCompositeSourceOver
				  fraction:1];

		int x = [left size].width;
		int totalwidth = imgsize.width - x - [right size].width;
		int midwidth = [mid size].width;

		while (totalwidth >= midwidth) {
			[mid drawAtPoint:NSMakePoint(x, 0)
					fromRect:NSZeroRect
				   operation:NSCompositeSourceOver
					fraction:1];
			x += midwidth;
			totalwidth -= midwidth;
		}

		if (totalwidth) {
			[mid drawAtPoint:NSMakePoint(x, 0)
					fromRect:NSMakeRect(0, 0, totalwidth, [mid size].height)
				   operation:NSCompositeSourceOver
					fraction:1];
		}

		[text drawAtPoint:point withAttributes:attrs];
		[img unlockFocus];
	}

	return img;
}

- (BOOL)matchesEvent:(NSEvent *)event ignoringModifiers:(NSEventModifierFlags)ignoredmods
{
	//	return [event _matchesKeyEquivalent:chr modifierMask:mod];

	NSEventModifierFlags eventmod = [event modifierFlags] & (NSEventModifierFlagCommand | NSEventModifierFlagOption | NSEventModifierFlagControl | NSEventModifierFlagShift) & ~ignoredmods;
	NSEventModifierFlags maskedmod = mod & ~ignoredmods;
	NSString *eventchr = [event remappedCharacters];
	NSString *nomodchr = [event remappedCharactersIgnoringAllModifiers];

	if (![eventchr isEqual:nomodchr]) {
		if ([chr isEqual:eventchr]) {
			if (((maskedmod ^ eventmod) & ~((NSEventModifierFlagOption | NSEventModifierFlagShift) & eventmod)) == 0) {
				return YES;
			}
		}
	}

	if ([chr isEqual:nomodchr]) {
		if ((maskedmod ^ eventmod) == 0) {
			return YES;
		}
	}

	return NO;
}

- (NSString *)description
{
	return [[self descriptionOfModifiers] stringByAppendingString:[self descriptionOfCharacter]];
}

- (NSString *)descriptionOfModifiers
{
	NSMutableString *str = [NSMutableString string];

	if (mod & NSEventModifierFlagCommand)
		[str appendString:@"\u2318"];
	if (mod & NSEventModifierFlagOption)
		[str appendString:@"\u2325"];
	if (mod & NSEventModifierFlagControl)
		[str appendString:@"\u2303"];
	if ((mod & NSEventModifierFlagShift) || ![[chr lowercaseString] isEqual:chr])
		[str appendString:@"\u21e7"];

	return [NSString stringWithString:str];
}

- (NSString *)descriptionOfCharacter
{
	if (!chr || ![chr length]) {
		return @"(Empty)";
	}
	switch ([chr characterAtIndex:0]) {
	case NSEnterCharacter:
		return @"\u2305";
	case NSBackspaceCharacter:
		return @"\u232b";
	case NSTabCharacter:
		return @"\u21e5";
	case NSCarriageReturnCharacter:
		return @"\u21a9";
	case NSBackTabCharacter:
		return @"\u21e4";
	case 16:
		return @"DLE"; // Context menu key on PC keyboard, ASCII DLE.
	case 27:
		return @"\u238b"; // esc
	case ' ':
		return @"Space";
	case NSDeleteCharacter:
		return @"\u2326";
	case NSUpArrowFunctionKey:
		return @"\u2191";
	case NSDownArrowFunctionKey:
		return @"\u2193";
	case NSLeftArrowFunctionKey:
		return @"\u2190";
	case NSRightArrowFunctionKey:
		return @"\u2192";
	case NSF1FunctionKey:
		return @"F1";
	case NSF2FunctionKey:
		return @"F2";
	case NSF3FunctionKey:
		return @"F3";
	case NSF4FunctionKey:
		return @"F4";
	case NSF5FunctionKey:
		return @"F5";
	case NSF6FunctionKey:
		return @"F6";
	case NSF7FunctionKey:
		return @"F7";
	case NSF8FunctionKey:
		return @"F8";
	case NSF9FunctionKey:
		return @"F9";
	case NSF10FunctionKey:
		return @"F10";
	case NSF11FunctionKey:
		return @"F11";
	case NSF12FunctionKey:
		return @"F12";
	case NSF13FunctionKey:
		return @"F13";
	case NSF14FunctionKey:
		return @"F14";
	case NSF15FunctionKey:
		return @"F15";
	case NSF16FunctionKey:
		return @"F16";
	case NSF17FunctionKey:
		return @"F17";
	case NSF18FunctionKey:
		return @"F18";
	case NSF19FunctionKey:
		return @"F19";
	case NSF20FunctionKey:
		return @"F20";
	case NSF21FunctionKey:
		return @"F21";
	case NSF22FunctionKey:
		return @"F22";
	case NSF23FunctionKey:
		return @"F23";
	case NSF24FunctionKey:
		return @"F24";
	case NSF25FunctionKey:
		return @"F25";
	case NSF26FunctionKey:
		return @"F26";
	case NSF27FunctionKey:
		return @"F27";
	case NSF28FunctionKey:
		return @"F28";
	case NSF29FunctionKey:
		return @"F29";
	case NSF30FunctionKey:
		return @"F30";
	case NSF31FunctionKey:
		return @"F31";
	case NSF32FunctionKey:
		return @"F32";
	case NSF33FunctionKey:
		return @"F33";
	case NSF34FunctionKey:
		return @"F34";
	case NSF35FunctionKey:
		return @"F35";
	case NSInsertFunctionKey:
		return @"Insert";
	//case NSDeleteFunctionKey: @"\u2326";
	case NSDeleteFunctionKey:
		return @"(invalid)";
	case NSHomeFunctionKey:
		return @"\u2196";
	case NSEndFunctionKey:
		return @"\u2198";
	case NSPageUpFunctionKey:
		return @"\u21de";
	case NSPageDownFunctionKey:
		return @"\u21df";
	case NSClearLineFunctionKey:
		return @"\u2327";
	case NSHelpFunctionKey:
		return @"?\u20dd";
	default:
		return [chr uppercaseString];
		//		default: return [NSString stringWithFormat:@"%d",[character characterAtIndex:0]];
	}
}

@end

// CSKeyboardList

@implementation CSKeyboardList
@synthesize keyboardShortcuts;

- (id)initWithCoder:(NSCoder *)decoder
{
	if (self = [super initWithCoder:decoder]) {
		selected = nil;
		dropaction = nil;
		dropbefore = nil;
		dropsize = NSZeroSize;

		keyboardShortcuts = nil;
	}
	return self;
}

- (void)awakeFromNib
{
	[super awakeFromNib];
	NSImageCell *cell = [[self tableColumnWithIdentifier:@"shortcuts"] dataCell];
	[cell setImageAlignment:NSImageAlignLeft];
	[cell setImageScaling:NSImageScaleNone];
	[self setRowHeight:18];
	[self setMatchAlgorithm:KFPrefixMatchAlgorithm];
	[self setSearchColumnIdentifiers:[NSSet setWithObject:@"title"]];

	[self setDoubleAction:@selector(addShortcut:)];

	if (!keyboardShortcuts) {
		keyboardShortcuts = [CSKeyboardShortcuts defaultShortcuts];
	}

	[self registerForDraggedTypes:@[ @"CSKeyStroke" ]];

	[self setDelegate:self];
	[self setDataSource:self];
	[self reloadData];
	[self performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
	[self updateButtons];
}

- (id)tableView:(NSTableView *)table objectValueForTableColumn:(NSTableColumn *)column row:(NSInteger)row
{
	if ([[column identifier] isEqual:@"title"]) {
		return [[[keyboardShortcuts actions] objectAtIndex:row] title];
	} else if ([[column identifier] isEqual:@"shortcuts"]) {
		CSAction *action = [[keyboardShortcuts actions] objectAtIndex:row];

		if (action == dropaction) {
			NSImage *image = [[NSImage alloc] initWithSize:[action imageSizeWithDropSize:dropsize]];
			[image lockFocus];
			[action drawAtPoint:NSZeroPoint selected:selected dropBefore:dropbefore dropSize:dropsize];
			[image unlockFocus];
			return image;
		} else if (row == [self selectedRow] && selected) {
			if (![[action shortcuts] count]) {
				return nil;
			}
			NSImage *image = [[NSImage alloc] initWithSize:[action imageSizeWithDropSize:NSZeroSize]];
			[image lockFocus];
			[action drawAtPoint:NSZeroPoint selected:selected dropBefore:nil dropSize:NSZeroSize];
			[image unlockFocus];
			return image;
		} else {
			return [action shortcutsImage];
		}
	}

	return nil;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)table
{
	return [[keyboardShortcuts actions] count];
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
	selected = nil;
	[self updateButtons];
}

- (BOOL)performKeyEquivalent:(NSEvent *)event
{
	NSString *chr = [event charactersIgnoringModifiers];
	if ([chr length]) {
		switch ([chr characterAtIndex:0]) {
		case NSDeleteCharacter:
		case NSDeleteFunctionKey:
			if (selected) {
				[self removeShortcut:nil];
				return YES;
			}
			break;
		}
	}
	return NO;
}

- (void)mouseDown:(NSEvent *)event
{
	NSPoint clickpoint = [self convertPoint:[event locationInWindow] fromView:nil];
	NSRect cellframe;
	CSAction *action = [self getActionForLocation:clickpoint hasFrame:&cellframe];

	if (action) {
		[self selectRowIndexes:[NSIndexSet indexSetWithIndex:[self rowAtPoint:clickpoint]] byExtendingSelection:NO];

		CSKeyStroke *clicked = [action findKeyAtPoint:clickpoint offset:cellframe.origin];
		//[action setSelected:[self findKeyAtPoint:clickpoint]];
		selected = clicked;
		[self reloadData];
		[self updateButtons];

		if (clicked) {
			NSEvent *newevent = [[self window] nextEventMatchingMask:(NSLeftMouseDraggedMask | NSLeftMouseUpMask)
														   untilDate:[NSDate distantFuture]
															  inMode:NSEventTrackingRunLoopMode
															 dequeue:YES];

			if (newevent && [newevent type] == NSLeftMouseDragged) {
				NSPasteboard *pboard = [NSPasteboard pasteboardWithName:NSDragPboard];
				[pboard declareTypes:@[ @"CSKeyStroke" ] owner:self];
				[pboard setData:[NSArchiver archivedDataWithRootObject:[clicked dictionary]] forType:@"CSKeyStroke"];

				NSPoint newpoint = [self convertPoint:[newevent locationInWindow] fromView:nil];
				NSPoint imgpoint = [action findLocationOfKey:clicked offset:cellframe.origin];

				NSMutableArray *newshortcuts = [[action shortcuts] mutableCopy];
				[newshortcuts removeObject:clicked];
				[action setShortcuts:newshortcuts];

				NSImage *keyimage = [clicked image];
				NSSize keysize = [keyimage size];
				NSImage *dragimage = [[NSImage alloc] initWithSize:keysize];

				[dragimage lockFocus];
				[keyimage drawAtPoint:NSMakePoint(0, 0)
							 fromRect:NSMakeRect(0, 0, keysize.width, keysize.height)
							operation:NSCompositeSourceOver
							 fraction:0.66];
				[dragimage unlockFocus];

				imgpoint.y += keysize.height;

				selected = nil;
				[self updateButtons];

				[[NSCursor arrowCursor] push];

				//TODO: [self beginDraggingSessionWithItems:(nonnull NSArray<NSDraggingItem *> *) event:event source:self];
				[self dragImage:dragimage
							 at:imgpoint
						 offset:NSMakeSize(newpoint.x - clickpoint.x, newpoint.y - clickpoint.y)
						  event:event
					 pasteboard:pboard
						 source:self
					  slideBack:NO];

				[NSCursor pop];
			}
			return;
		}
	}

	[super mouseDown:event];
}

- (NSDragOperation)draggingSourceOperationMaskForLocal:(BOOL)local
{
	return NSDragOperationMove | NSDragOperationDelete;
}

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
	return NSDragOperationMove | NSDragOperationDelete;
}

- (void)draggedImage:(NSImage *)image endedAt:(NSPoint)point operation:(NSDragOperation)operation
{
	if (operation != NSDragOperationMove) {
		NSShowAnimationEffect(NSAnimationEffectDisappearingItemDefault,
							  [[self window] convertBaseToScreen:[[self window] mouseLocationOutsideOfEventStream]],
							  NSZeroSize, nil, nil, nil);
	}
}

- (NSDragOperation)draggingEntered:(id<NSDraggingInfo>)sender
{
	return NSDragOperationMove;
}

- (NSDragOperation)draggingUpdated:(id<NSDraggingInfo>)sender
{
	NSRect cellframe;
	dropaction = [self getActionForLocation:[self convertPoint:[sender draggingLocation] fromView:nil] hasFrame:&cellframe];

	if (dropaction) {
		dropsize = [[sender draggedImage] size];
		dropbefore = [dropaction findKeyAfterDropPoint:[self convertPoint:[sender draggedImageLocation] fromView:nil] offset:cellframe.origin];

		[[NSCursor arrowCursor] set];
		[self reloadData];
		return NSDragOperationMove;
	} else {
		dropbefore = nil;
		dropsize = NSZeroSize;

		[[NSCursor disappearingItemCursor] set];
		[self reloadData];
		return NSDragOperationNone;
	}
}

- (void)draggingExited:(id<NSDraggingInfo>)sender
{
	dropaction = nil;
	dropbefore = nil;
	dropsize = NSZeroSize;

	[[NSCursor disappearingItemCursor] set];
	//SetThemeCursor(kThemePoofCursor);
	[self reloadData];
}

- (BOOL)performDragOperation:(id<NSDraggingInfo>)sender
{
	NSPasteboard *pboard = [sender draggingPasteboard];
	if (dropaction && [[pboard types] containsObject:@"CSKeyStroke"]) {
		CSKeyStroke *stroke = [CSKeyStroke keyFromDictionary:[NSUnarchiver unarchiveObjectWithData:[pboard dataForType:@"CSKeyStroke"]]];
		NSMutableArray *newshortcuts = [NSMutableArray arrayWithArray:[dropaction shortcuts]];

		if (dropbefore) {
			NSInteger index = [newshortcuts indexOfObjectIdenticalTo:dropbefore];
			[newshortcuts insertObject:stroke atIndex:index];
		} else {
			[newshortcuts addObject:stroke];
		}

		[dropaction setShortcuts:newshortcuts];
		selected = stroke;
	}

	dropaction = nil;
	dropbefore = nil;
	dropsize = NSZeroSize;

	[self reloadData];
	[self updateButtons];

	return YES;
}

- (CSAction *)getActionForLocation:(NSPoint)point hasFrame:(NSRect *)frame
{
	NSInteger rowindex = [self rowAtPoint:point];
	NSInteger colindex = [self columnAtPoint:point];

	if (colindex >= 0 && rowindex >= 0) {
		NSTableColumn *col = [[self tableColumns] objectAtIndex:colindex];

		if ([[col identifier] isEqual:@"shortcuts"]) {
			if (frame) {
				*frame = [self frameOfCellAtColumn:colindex row:rowindex];
			}
			return [[keyboardShortcuts actions] objectAtIndex:rowindex];
		}
	}
	return nil;
}

- (void)updateButtons
{
	BOOL rowsel = [self selectedRow] >= 0;

	[addButton setEnabled:rowsel];
	[removeButton setEnabled:selected != nil];
	[resetButton setEnabled:rowsel];
}

- (void)setKeyboardShortcuts:(CSKeyboardShortcuts *)shortcuts
{
	keyboardShortcuts = shortcuts;

	[self setDataSource:self];
	[self reloadData];
}

- (CSAction *)getSelectedAction
{
	return [[keyboardShortcuts actions] objectAtIndex:[self selectedRow]];
}

- (IBAction)addShortcut:(id)sender
{
	NSInteger rowindex = [self selectedRow];
	if (rowindex < 0) {
		return;
	}

	CSAction *action = [[keyboardShortcuts actions] objectAtIndex:rowindex];

	[infoTextField setStringValue:NSLocalizedString(@"Press the keys you want as a shortcut for this action.", @"Text asking the user to press keys when assigning a new keyboard shortcut")];

	NSEvent *event = [[self window] nextEventMatchingMask:(NSKeyDownMask | NSLeftMouseDownMask)
												untilDate:[NSDate dateWithTimeIntervalSinceNow:10]
												   inMode:NSEventTrackingRunLoopMode
												  dequeue:YES];

	if (event && [event type] == NSKeyDown) {
		NSInteger otherrow;
		CSKeyStroke *other = [keyboardShortcuts findKeyStrokeForEvent:event index:&otherrow];

		if (other) {
			[self selectRowIndexes:[NSIndexSet indexSetWithIndex:otherrow] byExtendingSelection:NO];
			[self scrollRowToVisible:otherrow];
			selected = other;
			[infoTextField setStringValue:NSLocalizedString(@"This shortcut is already in use.", @"Text explaining that an entered keyboard shortcut is already in use")];
		} else {
			CSKeyStroke *stroke = [CSKeyStroke keyFromEvent:event];

			[action setShortcuts:[[action shortcuts] arrayByAddingObject:stroke]];
			selected = stroke;
			[infoTextField setStringValue:@""];
		}

		[self reloadData];
		[self updateButtons];

		NSEvent *upevent = [[self window] nextEventMatchingMask:NSKeyUpMask
													  untilDate:[NSDate distantFuture]
														 inMode:NSEventTrackingRunLoopMode
														dequeue:YES];
		[[self window] discardEventsMatchingMask:NSAnyEventMask beforeEvent:upevent];
	} else {
		[infoTextField setStringValue:@""];
	}
}

- (IBAction)removeShortcut:(id)sender
{
	if (!selected) {
		return;
	}
	NSInteger rowindex = [self selectedRow];
	if (rowindex < 0) {
		return;
	}

	CSAction *action = [[keyboardShortcuts actions] objectAtIndex:rowindex];

	NSMutableArray *newshortcuts = [[action shortcuts] mutableCopy];
	[newshortcuts removeObjectIdenticalTo:selected];
	[action setShortcuts:newshortcuts];

	selected = nil;

	[self reloadData];
	[self updateButtons];
}

- (IBAction)resetToDefaults:(id)sender
{
	NSInteger rowindex = [self selectedRow];
	if (rowindex < 0) {
		return;
	}

	CSAction *action = [[keyboardShortcuts actions] objectAtIndex:rowindex];

	[action resetToDefaults];
	selected = nil;

	[self reloadData];
	[self updateButtons];
}

- (IBAction)resetAll:(id)sender
{
	[keyboardShortcuts resetToDefaults];

	selected = nil;

	[self reloadData];
	[self updateButtons];
}

@end

// CSKeyListenerWindow

@implementation CSKeyListenerWindow

+ (void)install
{
#if !__OBJC2__
	[self poseAsClass:[NSWindow class]];
#endif
}

- (BOOL)performKeyEquivalent:(NSEvent *)event
{
	if (![self isKindOfClass:[NSPanel class]]) {
		if ([event type] == NSKeyDown) { // maybe I should just use keyDown?
			if ([defaultshortcuts handleKeyEvent:event]) {
				return YES;
			}
		}
	}

	return [super performKeyEquivalent:event];
}

@end

// NSEvent additions

@implementation NSEvent (CSKeyboardShortcutsAdditions)

+ (NSString *)remapCharacters:(NSString *)characters
{
	static NSDictionary *remapdictionary = nil;
	if (!remapdictionary) {
		remapdictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
													[NSString stringWithFormat:@"%C", (unichar)NSBackspaceCharacter],
													[NSString stringWithFormat:@"%C", (unichar)NSDeleteCharacter],

													[NSString stringWithFormat:@"%C", (unichar)NSDeleteCharacter],
													[NSString stringWithFormat:@"%C", (unichar)NSDeleteFunctionKey],
													nil];
	}

	NSString *remapped = [remapdictionary objectForKey:characters];
	if (remapped) {
		return remapped;
	} else {
		return characters;
	}
}

- (NSString *)charactersIgnoringAllModifiers
{
	unsigned short keycode = [self keyCode];

	TISInputSourceRef layout;
	const void *uchr = NULL;
	layout = TISCopyCurrentKeyboardLayoutInputSource();
	NSData *tmpData = (__bridge id)TISGetInputSourceProperty(layout, kTISPropertyUnicodeKeyLayoutData);
	uchr = [tmpData bytes];
	CFRelease(layout);

	if (uchr) {
		UInt32 state = 0;
		UniCharCount strlen;
		UniChar c;

		UCKeyTranslate(uchr, keycode, kUCKeyActionDown, 0, LMGetKbdType(), 0, &state, 1, &strlen, &c);
		if (state != 0)
			UCKeyTranslate(uchr, keycode, kUCKeyActionDown, 0, LMGetKbdType(), 0, &state, 1, &strlen, &c);

		if (strlen && c >= 32 && c != 127) { // control chars are not reliable!
			return [NSString stringWithCharacters:&c length:strlen];
		}
	}

	return [[self charactersIgnoringModifiers] lowercaseString];
}

- (NSString *)remappedCharacters
{
	return [NSEvent remapCharacters:[self characters]];
}

- (NSString *)remappedCharactersIgnoringAllModifiers
{
	return [NSEvent remapCharacters:[self charactersIgnoringAllModifiers]];
}

@end
