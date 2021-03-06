//
//  viXcode.m
//  viXcode
//
//  Created by Broken Rim on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "viXcode.h"

NSUInteger viXcode_decrement(NSUInteger value) {
    NSUInteger result = value - 1;
    if ( result > value ) {
        result = 0;
    }
    return result;
}

@implementation viXcode

+ (void) load {
   NSLog(@"(viXcode)");
}

+ (viXcode *)singleton {
    static viXcode *instance = nil;
    if (!instance) {
        instance = [[[self class] alloc] init];
    }
    return instance;
}

- (id)init {
    self = [super initWithWindowNibName:@"viXcodeWindow" owner:self];
    if (self) {
        [self setWindowFrameAutosaveName:@"viXcodeWindow"];
		[[self window] setDelegate:self];
		[[self window] setHasShadow:NO];
        [[self window] setBackgroundColor:[NSColor clearColor]];
        [[self window] setOpaque:NO];
        [[self window] setAlphaValue:0.75];

        mode0_key2selector = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"vi_leftBrace", @"{",
                                @"vi_rightBrace", @"}",
                                @"vi_caret", @"^",
                                @"vi_colon", @":",
                                @"vi_questionmark", @"?",
                                @"vi_slash", @"/",
                                @"vi_dollar", @"$",
                                @"vi_0", @"0",
                                @"vi_123456789", @"1",
                                @"vi_123456789", @"2",
                                @"vi_123456789", @"3",
                                @"vi_123456789", @"4",
                                @"vi_123456789", @"5",
                                @"vi_123456789", @"6",
                                @"vi_123456789", @"7",
                                @"vi_123456789", @"8",
                                @"vi_123456789", @"9",
                                @"vi_A", @"A",
                                @"vi_c", @"c",
                                @"vi_e", @"e",
                                @"vi_E", @"E",
                                @"vi_G", @"G",
                                @"vi_I", @"I",
                                @"vi_l", @"l",
                                @"vi_n", @"n",
                                @"vi_N", @"N",
                                @"vi_h", @"h",
                                @"vi_j", @"j",
                                @"vi_J", @"J",
                                @"vi_k", @"k",
                                @"vi_r", @"r",
                                @"vi_x", @"x",
                                @"vi_X", @"X",
                                @"vi_w", @"w",
                                @"vi_w", @"W",
                                @"vi_b", @"b",
                                @"vi_b", @"B",
                                @"vi_u", @"u",
                                @"vi_U", @"U",
                                @"vi_o", @"o",
                                @"vi_O", @"O",
                                @"vi_i", @"i",
                                @"vi_a", @"a",
                                @"vi_d", @"d",
                                @"vi_p", @"p",
                                @"vi_g", @"g",
                                nil];

        mode1_key2selector = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"vi_dd", @"dd",
                                @"vi_dh", @"hh",
                                @"vi_dk", @"k",
                                @"vi_dj", @"dj",
                                @"vi_dl", @"dl",
                                @"vi_dw", @"dw",
                                @"vi_ddollar", @"d$",
                                @"vi_cw", @"cw",
                                @"vi_gg", @"gg",
                                nil];

		lastSearchTarget = [[NSMutableString stringWithCapacity:16] retain];
    }
    
    return self;
}

- (void)showWindowIfNeeded:(id)sender; {
    NSWindow *searchWindow = [self window];
    if(![searchWindow isVisible]) {
		
        NSView *view = [sender enclosingScrollView];
        if (view == nil) view = sender;
        NSWindow *textFieldWindow = [view window];
        NSRect textFieldRect;
        NSPoint textFieldBottomLeft;
		NSRect  searchWindowFrame = [searchWindow frame];
		
		if ([view isKindOfClass:[NSScrollView class]]) {
			textFieldRect = [view convertRect: [[(NSScrollView*)view contentView] frame] toView: nil];
			textFieldBottomLeft = NSMakePoint(textFieldRect.origin.x, textFieldRect.origin.y);
            textFieldBottomLeft.x += textFieldRect.size.width * 0.25;
			searchWindowFrame.origin = [textFieldWindow convertBaseToScreen: textFieldBottomLeft];
        }
        else {
			textFieldRect = [view convertRect: [view bounds] toView: nil];
            // textFieldBottomLeft might be misnamed here
			textFieldBottomLeft = NSMakePoint(textFieldRect.origin.x, textFieldRect.origin.y);
            textFieldBottomLeft.x += textFieldRect.size.width * 0.25;
			searchWindowFrame.origin = [textFieldWindow convertBaseToScreen: textFieldBottomLeft];
			searchWindowFrame.origin.y -= searchWindowFrame.size.height;
		}
        searchWindowFrame.size.width = textFieldRect.size.width * 0.5;
        
        [searchWindow setFrame:searchWindowFrame display:YES];
    }
    [self showWindow:self];
	// mode = 0;
}

- (void)windowDidResignKey:(NSNotification*)notification {
	[textField setStringValue:@""];
	[[self window] close];
}

- (IBAction)open:(id)sender{
    // If you press <ESC> while the window is already active
    // Clear showAction, clear input, etc?
    [textField setStringValue:@""];
    [self showWindowIfNeeded:sender];
    [self keyPressed:sender];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    [self keyPressed:self];
}

// Enter was pressed in textField
- (IBAction)textFieldAction:(id)sender {

	switch (mode) {
		case 2:
			if (searchRepeat) {
				NSString* textFieldText;
				if (searchForward)
					textFieldText = [@"/" stringByAppendingString:lastSearchTarget];
				else
					textFieldText = [@"?" stringByAppendingString:lastSearchTarget];
				
				[textField setStringValue:textFieldText];
				[self keyPressed:self];
			}
			// When vi ends a search, it does not enter input mode
			mode = 0;
			break;
		//case 5:
		//    [self handleMode5];
		//    mode = 0;
		//    break;
		default:
			mode = 0;
			break;
	}
	
	// Focus switches off to the desktop otherwise?
	[[self window] makeFirstResponder: textField];
	[textField setStringValue:@""];
}

- (IBAction)keyPressed:(id)sender {
	id targetWindow = [NSApp mainWindow];
    firstResponder = [targetWindow firstResponder];

	if ([firstResponder isKindOfClass:[NSTextView class]]) {
		input = [textField stringValue];
		
        NSLog(@"input: \"%@\" %lu", input, (unsigned long) [input length]);

		if ([input length] < 1) {
			mode = 0;
			return;
		}

		locationShift = 0;
		selectionSize = 1;
		saveInput = NO;

		switch (mode) {
			case 0: {
				NSString* firstKey = [input substringToIndex:1];
                [self selectorDispatch:mode0_key2selector withKey:firstKey];
			}
            break;

            // c (cw), d (dd), ...
            case 1: {
				[self handleMode1];
				
				if (!saveInput)
					[textField setStringValue:@""];
            }
            break;

            // Search
			case 2: {
				saveInput = YES;
				[self handleSearch:[input substringFromIndex:1]];
				if (!saveInput)
					[textField setStringValue:@""];
			}
            break;

            // A number is being entered (vi_G)
			case 3: {
				[self handleMode3];
				if (!saveInput)
					[textField setStringValue:@""];
			}
            break;

            // Character replacement (vi_r)
            case 4: {
				[self handleMode_r];
				if (!saveInput)
					[textField setStringValue:@""];
            }
            break;
        }
    }
}

- (void)showAction:(NSString*)msg {
	[[self window] setTitle:msg];
}

- (void)vi_j {
	[self showAction:@"(j) - Cursor down"];
	[firstResponder moveDown:self];
}

- (void)vi_k {
	[self showAction:@"(k) - Cursor up"];
	[firstResponder moveUp:self];
}

- (void)vi_h {
	[self showAction:@"(h) - Cursor left"];
	[firstResponder moveLeft:self];
    locationShift = -1;
}

- (void)vi_l {
	[self showAction:@"(l) - Cursor right"];
	[firstResponder moveRight:self];
}

- (void)vi_dollar {
	[self showAction:@"($) - Jump to end of line"];
	[firstResponder moveToEndOfLine:self];
	locationShift = -1;
}

- (void)vi_0 {
	[self showAction:@"(0) - Jump to beginning of line"];
	[firstResponder moveToBeginningOfLine:self];
}

- (void)vi_I {
	[self showAction:@"(I) - Insert at beginning of line"];
	[firstResponder moveToBeginningOfLine:self];
	[[self window] orderOut:self];
	selectionSize = 0;
}

- (void)vi_i {
	[self showAction:@"(i) - Insert at cursor"];
	[[self window] orderOut:self];
	selectionSize = 0;
}

// TODO Should we handle this as vi-compatible mode... or consider wrapped lines, wrapped?
- (void)vi_A {
	[self showAction:@"(A) - Insert at end of line (append)"];
	[firstResponder moveToEndOfLine:self];
    [[self window] orderOut:self];
	selectionSize = 0;
}

- (void)vi_a {
	[self showAction:@"(a) - Insert to the right of the cursor"];
	[firstResponder moveRight:self];
	[[self window] orderOut:self];
	selectionSize = 0;
}

- (void)vi_w {
	[self showAction:@"(w) - Move one word to the right"];
	
	NSRange range = [firstResponder selectedRange];
	NSTextStorage* textStorage = [firstResponder textStorage];
	
	
	// At the end of the buffer, just return
	if (range.location + 1 >= [textStorage length])
		return;
	
	// It appears that the cocoa text system fails to move forward if the word is a 
	// single character (like 'a')
    // So, let's go and check if this is the case
	if (isspace([[textStorage string] characterAtIndex:(range.location+1)]))
	{
		[firstResponder moveRight:self];
		NSString* text = [textStorage string];
		// Continue moving right while we are still a space (isspace)
		unsigned long location = range.location+1;
		while (isspace([text characterAtIndex:location]))
		{
			[firstResponder moveRight:self];
			location++;
			if (location >= [textStorage length])
				return;
		}
	} 
	else
	{
        // Cocoa just moves to the end of the current word...
	    [firstResponder moveWordRight:self];
		// ...but vi moves to the beginning of the next word
		[firstResponder moveRight:self]; 
	}
}

- (void)vi_b {
	[self showAction:@"(b) - Move one word to the left"];
	[firstResponder moveWordLeft:self];
}

- (void)vi_u {
	[self showAction:@"(u) - Undo"];
    [[firstResponder undoManager] undo];
}

- (void)vi_U {
	[self showAction:@"(U) - Redo"];
    [[firstResponder undoManager] redo];
}

// FIXME These seem broken
- (void)vi_leftBrace {
	[self showAction:@"({) - Move to beginning of the previous paragraph"];
	// We have to move left until we hit the paragraph before we can issue the move call
	NSUInteger location = [firstResponder selectedRange].location;
	NSString* text = [[firstResponder textStorage] string];
	do {
        location = viXcode_decrement( location );
		if (location == 0) { 
			break;
		}
	} while (isspace([text characterAtIndex:location]));
	
	NSRange range = NSMakeRange(location, 1);
	[firstResponder setSelectedRange:range];
	[firstResponder moveToBeginningOfParagraph:self];
}

- (void)vi_rightBrace {
	[self showAction:@"(}) - Move to beginning of the next paragraph"];
	[firstResponder moveRight:self];
	[firstResponder moveToEndOfParagraph:self];
	[firstResponder moveRight:self];
}

// FIXME This may need some work
- (void)vi_e {
	[self showAction:@"(e) - Move to end of the word"];
	
	// There is no "move to end of word" motion
	// We will move to the word on the right, and then roll backwards
	NSRange range = [firstResponder selectedRange];
	NSTextStorage* textStorage = [firstResponder textStorage];
	
	// Return if we're at the end of the buffer
	if (range.location + 1 >= [textStorage length])
		return;
	
	NSString* text = [textStorage string];
	
    // Cocoa just moves to the end of the current word...
    [firstResponder moveWordRight:self];
    // ...but vi moves to the beginning of the next word
    [firstResponder moveRight:self]; 
	
	// Begin rolling back
	// (Continue to move back until we find an an alpha or a number
	range = [firstResponder selectedRange];
	NSUInteger location = viXcode_decrement( range.location );
	do {
		location = viXcode_decrement( location );
    } while (isspace([text characterAtIndex:location]));
	locationShift = location - range.location;
    // FIXME Possible overflow issue?
}


- (void)vi_G {
	[self showAction:@"(G) - Move to last line"];
	[firstResponder moveToEndOfDocument:self];
	[firstResponder moveToBeginningOfLine:self];
    selectionSize = 0;
}

- (void)vi_gg {
	[self showAction:@"(G) - Move to first line"];
	[firstResponder moveToBeginningOfDocument:self];
	[firstResponder moveToBeginningOfLine:self];
    selectionSize = 0;
}


- (void)vi_o {
	[self showAction:@"(o) - Insert at new line"];
	[firstResponder moveToEndOfLine:self];
	[firstResponder insertNewlineIgnoringFieldEditor:self];

	// Wrapping causes some problem here.  We now have to check if there is an
	// alpha character underneath the cursor (in the case of wrapping)
	// If there is, then we need to insert a second newline character
	NSRange range = [firstResponder selectedRange];
	NSString* text = [[firstResponder textStorage] string];
	if (!isspace([text characterAtIndex:range.location])) {
		[firstResponder insertNewlineIgnoringFieldEditor:self];
		[firstResponder moveUp:self];
	}
	[[self window] orderOut:self];
    selectionSize = 0;
}

- (void)vi_O {
    [self showAction:@"(O) - Insert a new line above"];
    NSRange range0 = [firstResponder selectedRange];
    [firstResponder moveUp:self];
    NSRange range1 = [firstResponder selectedRange];
    if (range0.location == range1.location)
    {
        [firstResponder moveToBeginningOfLine:self];
        [firstResponder insertNewlineIgnoringFieldEditor:self];
        [firstResponder moveUp:self];
        [[self window] orderOut:self];
        selectionSize = 0;	
        return;
    }

	// Wrapping causes some problem here.  We now have to check if there is an
	// alpha character underneath the cursor (in the case of wrapping)
	// If there is, then we need to insert a second newline character
	[firstResponder moveToEndOfLine:self];
	[firstResponder insertNewlineIgnoringFieldEditor:self];
	NSRange range = [firstResponder selectedRange];
	NSString* text = [[firstResponder textStorage] string];
	if (!isspace([text characterAtIndex:range.location])) {
		[firstResponder insertNewlineIgnoringFieldEditor:self];
		[firstResponder moveUp:self];
	}
	[[self window] orderOut:self];
    selectionSize = 0;
}

- (void)vi_c {
	[self showAction:@"(c) - Change ..."];
	mode = 1;
	saveInput = YES;
}

- (void)vi_d {
	[self showAction:@"(d) - Delete ..."];
	mode = 1;
	saveInput = YES;
}

- (void)vi_g {
	[self showAction:@"(g) - ..."];
	mode = 1;
	saveInput = YES;
}

- (void)selectorDispatch:(NSDictionary *)key2selector  withKey:(NSString *)key {
    NSString* selectorName = [key2selector objectForKey:key];
    
    NSLog(@"selectorName: %@", selectorName);
    if (selectorName != nil) {
        SEL selector_ = sel_registerName([selectorName UTF8String]);
        if (selector_ && [self respondsToSelector:selector_]) {
            [self performSelector:selector_];
        }
    }
    
    if (!saveInput) 
        [textField setStringValue:@""];
    
    NSTextStorage* textStorage = [firstResponder textStorage];
    NSRange range = [firstResponder selectedRange];
    
    // TODO Add try/catch here?
    range.location += locationShift;
    if ( range.location > [textStorage length] ) {
        range.location = [textStorage length];
        range.length = 0;
    }
    else if ( range.location + selectionSize > [textStorage length] ) {
        range.length = 0;
    }
    else {
        range.length = selectionSize;
    }

    [firstResponder setSelectedRange:range];
    [firstResponder scrollRangeToVisible:range];
}

- (void)vi_123456789 {
	[self showAction:@"(123456789) - Build number..."];
    mode = 3;
    saveInput = YES;
}

- (void)handleMode1 {
	
    NSInteger length = [input length];
    
    // First thing is a sanity check
    // The input should be two or more characters long
    if (length < 2) {
        // Try to gracefully recover
        [textField setStringValue:@""];
        mode = 0;
        return;
    }
    
    // Second thing to do is to see if the last character of "input" is a number
    // If it *is* a number, then we drop out and let the user continue typing
    unichar lastCharacter = [input characterAtIndex:(length-1)];
    if (isdigit(lastCharacter)) {
        saveInput = YES;
        return;
    }
    
    NSString* firstKey = [input substringToIndex:1];
    NSString* lastKey = [input substringFromIndex:(length-1)];
    mode1_repeatCount = 1;
    if (length > 2) {
        NSRange range = NSMakeRange(1,length-2);
        NSString* numberString = [input substringWithRange:range];
        mode1_repeatCount = [numberString intValue];
    }

    NSLog(@"mode1_repeatCount = %ld", (long) mode1_repeatCount);

    [self selectorDispatch:mode1_key2selector withKey:[firstKey stringByAppendingString:lastKey]];
	
    mode = 0;
}

- (void)vi_cw {
    [self showAction:[@"(cw) - Change word " stringByAppendingString:[NSString stringWithFormat:@"(%i)", mode1_repeatCount]]];
    NSInteger wordCount = mode1_repeatCount;
	[firstResponder setMark:self];
    NSRange range = [firstResponder selectedRange];
    range.length = 0;
    [firstResponder setSelectedRange:range];
    while ( wordCount > 0 ) {
        [firstResponder deleteWordForward:self];
        wordCount--;
    }
    [[self window] orderOut:self];
    selectionSize = 0;
}

- (void)vi_dd {
    [self showAction:[@"(dd) - Delete line " stringByAppendingString:[NSString stringWithFormat:@"(%i)", mode1_repeatCount]]];
	
	[firstResponder moveToBeginningOfLine:self];
	// If the user tries to delete more lines than there are in the document
    NSInteger lineCount = mode1_repeatCount;
	[firstResponder setMark:self];
    while ( lineCount > 0 ) {
        NSRange range0 = [firstResponder selectedRange];
        [firstResponder moveDown:self];
        NSRange range1 = [firstResponder selectedRange];
        if (range0.location == range1.location)
            break;
        lineCount--;
    }
	[firstResponder deleteToMark:self];
    // TODO selectionSize = 0?
}

// Different from "dd" in that it deletes from the current location
- (void)vi_dj {
    [self showAction:[@"(dj) - Delete line down " stringByAppendingString:[NSString stringWithFormat:@"(%i)", mode1_repeatCount]]];

	// If the user tries to delete more lines than there are in the document
    NSInteger lineCount = mode1_repeatCount;
	[firstResponder setMark:self];
    while ( lineCount > 0 ) {
        NSRange range0 = [firstResponder selectedRange];
        [firstResponder moveDown:self];
        NSRange range1 = [firstResponder selectedRange];
        if (range0.location == range1.location)
            break;
        lineCount--;
    }
	[firstResponder deleteToMark:self];
    // TODO selectionSize = 0?
}

- (void)vi_dk {
    [self showAction:[@"(dk) - Delete line up " stringByAppendingString:[NSString stringWithFormat:@"(%i)", mode1_repeatCount]]];

    NSInteger lineCount = mode1_repeatCount;

	[firstResponder moveToEndOfLine:self];
    [firstResponder setMark:self];
    while ( lineCount > 0 ) {
        lineCount--;
        [firstResponder moveUp:self];
    }
    [firstResponder moveToBeginningOfLine:self];
    [firstResponder deleteToMark:self];
}

- (BOOL)characterAtLocationIsNewline {
    NSRange range = [firstResponder selectedRange];
    NSString* text = [[firstResponder textStorage] string];
    unichar chr = [text characterAtIndex:range.location];
    return chr == '\n';
}

- (BOOL)characterAtLocationIsSpace {
    NSRange range = [firstResponder selectedRange];
    NSString* text = [[firstResponder textStorage] string];
    unichar chr = [text characterAtIndex:range.location];
    return isspace(chr);
}

- (void)vi_dl {
    [self showAction:[@"(dl) - Delete character right " stringByAppendingString:[NSString stringWithFormat:@"(%i)", mode1_repeatCount]]];

    if ([self characterAtLocationIsNewline]) {
        return;
    }

    NSInteger characterCount = mode1_repeatCount;
    [firstResponder setMark:self];
    while ( characterCount > 0 ) {
        [firstResponder moveRight:self];
        if ([self characterAtLocationIsNewline]) {
            [firstResponder moveLeft:self];
            break;
        }
        characterCount--;
    }
    [firstResponder deleteToMark:self];
    if ([self characterAtLocationIsNewline]) {
        [firstResponder moveLeft:self];
    }
}

- (void)vi_dh {
    [self showAction:[@"(dh) - Delete character left " stringByAppendingString:[NSString stringWithFormat:@"(%i)", mode1_repeatCount]]];

    if ([self characterAtLocationIsNewline]) {
        return;
    }

    NSInteger characterCount = mode1_repeatCount;
    [firstResponder moveLeft:self];
    [firstResponder setMark:self];
    while ( characterCount > 0 ) {
        NSRange range = [firstResponder selectedRange];
        if ( range.location > 0 ) {
            NSString* text = [[firstResponder textStorage] string];
            unichar chr = [text characterAtIndex:range.location - 1];
            if ( chr == '\n' ) {
                break;
            }
        }
        [firstResponder moveLeft:self];
        characterCount--;
    }
    [firstResponder deleteToMark:self];
}

- (BOOL)moveDownToDifferentLine {
    NSRange range0 = [firstResponder selectedRange];
    [firstResponder moveDown:self];
    NSRange range1 = [firstResponder selectedRange];
    return range0.location != range1.location;
}

- (void)vi_ddollar {
    [self showAction:@"(d$) - Delete to end of line"];
    
    NSRange range = [firstResponder selectedRange];
    range.length = 0;
    [firstResponder setSelectedRange:range];
    [firstResponder deleteToEndOfLine:self];

    NSInteger lineCount = mode1_repeatCount - 1;
    if ( lineCount && [self moveDownToDifferentLine] ) {
        lineCount--;
        [firstResponder moveToBeginningOfLine:self];
        [firstResponder setMark:self];
        while ( lineCount > 0 ) {
            if (![self moveDownToDifferentLine]) break;
            lineCount--;
        }
        [firstResponder moveToEndOfLine:self];
        [firstResponder deleteToMark:self];
    }
    // TODO selectionSize = 0?
    //range.length = 1;
    //range.location = (range.location == 0) ? 0 : range.location - 1 ;
    //[firstResponder setSelectedRange:range];
}

- (void)vi_x {
	[self showAction:@"(x) - Delete character"];
    mode1_repeatCount = 1;
    [self vi_dl];
}

- (void)vi_X {
	[self showAction:@"(x) - Delete character"];
    mode1_repeatCount = 1;
    [self vi_dh];
}

- (void)vi_dw {
    [self showAction:[@"(dw) - Delete word " stringByAppendingString:[NSString stringWithFormat:@"(%i)", mode1_repeatCount]]];

    // FIXME dw => dh when at the end of the line
    // FIXME Better consideration of what is a word
    NSRange range = [firstResponder selectedRange];
    range.length = 0;
    [firstResponder setSelectedRange:range];
    NSInteger wordCount = mode1_repeatCount;
    while ( wordCount > 0 ) {
        [firstResponder deleteWordForward:self];
        wordCount--;
    }
    if ( [self characterAtLocationIsSpace] ) {
        [firstResponder deleteForward:self];
    }
}

- (void)vi_caret {
	[self showAction:@"(^) - First non-blank character"];
	[firstResponder moveToBeginningOfLine:self];
	// Move to the right until we hit a character
	NSUInteger location = [firstResponder selectedRange].location;
	NSString* text = [[firstResponder textStorage] string];
    NSUInteger textLength = [text length];
    if (location < textLength) {
        while (isspace([text characterAtIndex:location])) {
            location++;
            if (location >= textLength) {
                location = textLength - 1;
                break;
            }
        } 
    }
    NSRange range = NSMakeRange(location, location < textLength ? 1 : 0);
    [firstResponder setSelectedRange:range];
}

- (void)vi_slash {
    [self showAction:@"(/) - Search forward"];
    mode = 2;
    saveInput = YES;
    searchForward = YES;
    searchInitial = YES;
    searchRepeat = NO;
    // We need to indicate if there was a past search to repeat
    if (![lastSearchTarget isEqualToString:@""]) {
        searchRepeat = YES;
    } 
    else { // Only unset wrapping if new, otherwise keep the value
        searchWrap = NO;
    }
}

- (void)vi_questionmark {
    [self showAction:@"(/) - Search backward"];
	mode = 2;
    saveInput = YES;
    searchForward = NO;
    searchInitial = YES;
    searchRepeat = NO;
    // We need to indicate if there was a past search to repeat
    if (![lastSearchTarget isEqualToString:@""]) {
        searchRepeat = YES;
    } 
    else { // Only unset wrapping if new, otherwise keep the value
        searchWrap = NO;
    }
}

- (void)handleSearch:(NSString *)searchTarget {
    NSRange range;
    NSString *title = nil;
    NSString *string = [firstResponder string];
    NSUInteger textLength = [[firstResponder textStorage] length];
    
    // Always turn this off here?
    searchRepeat = NO;
    
    [lastSearchTarget setString:searchTarget];
    int options = 0;
    
    if (!searchForward) {
        options |= NSBackwardsSearch;
    }
    
    if ([searchTarget rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location == NSNotFound) {
        options |= NSCaseInsensitiveSearch;
    }
    
    NSRange selectedRange = [firstResponder selectedRange];
    
    // Guarantee that we're always searching to the extent of the range we want
    if (searchForward) {
        if (searchInitial) {
            searchRange.location = [firstResponder selectedRange].location + 1;
        }
        searchRange.length = textLength - searchRange.location; // We're always searching to the end
    }
    else {
        searchRange.location = 0;
        if (searchInitial)
            searchRange.length = selectedRange.location;
    }
    
    if (searchWrap){
        searchRange = NSMakeRange(0, textLength);
    }
    
    
    range = [string rangeOfString:searchTarget
                          options:options
                            range:searchRange];
    
    
    if (range.location == NSNotFound) {
        if (!searchInitial) NSBeep();
        
        title = [NSString stringWithFormat:NSLocalizedString(@"(/) - Not found%@", @""), 
                 (searchWrap ? NSLocalizedString(@" (wrapped)", @"") : @"")];
        
        if (!searchForward) title = [title stringByAppendingString:NSLocalizedString(@" (backward)",@"")];
        
        searchWrap = YES;
        [[self window] setTitle:title];
        return;
    }
    else {
        if (searchForward) {
            searchRange = NSMakeRange( range.location, (textLength - range.location) );
        }
        title = [NSString stringWithFormat:NSLocalizedString(@"(/) - Found%@", @""),
                 (searchWrap ? @" (wrapped)" : @"")];
        
        if (!searchForward) title = [title stringByAppendingString:NSLocalizedString(@" (backward)",@"")];
        
        searchInitial = NO;
        searchWrap = NO;
        [self showAction:title];
    }
    
    [firstResponder setSelectedRange:range];
    [firstResponder scrollRangeToVisible:range];
}

- (void)vi_n {
	searchInitial = YES;
	[self handleSearch:lastSearchTarget];
	mode = 0;
}

- (void)vi_N {
    BOOL searchWasForward = searchForward;
    searchForward = !searchForward;
    searchInitial = YES;
	[self handleSearch:lastSearchTarget];
	mode = 0;
    searchForward = searchWasForward;
}

- (NSUInteger)getIndexForLineNumber:(NSUInteger)number ofString: (NSString*)string {
	NSUInteger numberOfLines, index, stringLength = [string length];
	
	if ( number == 1 )
		return 0;
	
	for ( index = 0, numberOfLines = 1; (index < stringLength) && (numberOfLines < number); numberOfLines++ ) {	
        NSLog(@"%lu", (unsigned long) index);
		index = NSMaxRange([string lineRangeForRange:NSMakeRange(index, 0)]);
	}
	
	return index;
}

- (void)handleMode3 {
	
    NSInteger length = [input length];
    
    // First thing is a sanity check
    // The input should be two or more characters long
    if (length < 2) {
        // Try to gracefully recover
        [textField setStringValue:@""];
        mode = 0;
        return;
    }
	
    // Second thing to do is to see if the last character of "input" is a number
    // If it *is* a number, then we drop out and let the user continue typing
    unichar lastCharacter = [input characterAtIndex:(length-1)];
    if (isdigit(lastCharacter)) {
        saveInput = YES;
        return;
    }
	
    NSString* lastKey = [input substringFromIndex:(length-1)];
	if ([lastKey isEqualToString:@"G"])
	{
        NSRange range = NSMakeRange(0, length - 1);
        NSString *numberString = [input substringWithRange:range];
		NSUInteger lineNumber = [numberString intValue];
		[self showAction:[NSString stringWithFormat:@"(G) Moving to line %i", lineNumber]];
		
        NSString *string = [firstResponder string];
		NSInteger index = [self getIndexForLineNumber:lineNumber ofString:string];

        [firstResponder setSelectedRange:NSMakeRange( index, index < [string length] ? 1 : 0 )];
	}
	else {
		NSBeep();
    }
	
	saveInput = NO;
	mode = 0;
	
}

- (void)vi_r {	
	[self showAction:@"(r) - Character replacement"];

	saveInput = YES;
    mode = 4;
}

// AKA handleMode4
- (void)handleMode_r {
	
    NSInteger length = [input length];
	
    NSLog(@"input: %@", input);
    // First thing is a sanity check
    // The input should be two or more characters long
    if (length < 2) {
        // Try to gracefully recover
        [textField setStringValue:@""];
        mode = 0;
        return;
    }
	
	NSRange range = [firstResponder selectedRange];
	range.length = 1;
	NSString* replaceString = [input substringFromIndex:(length - 1)];
	[firstResponder replaceCharactersInRange:range withString:replaceString];
	[firstResponder setSelectedRange:range];
	
	saveInput = NO;
	mode = 0;
}

// TODO vi_g

- (void)dealloc {
    [super dealloc];
}

@end
