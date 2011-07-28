//
//  viXcode4.m
//  viXcode4
//
//  Created by Broken Rim on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "viXcode4.h"

NSUInteger viXcode4_decrement(NSUInteger value) {
    NSUInteger result = value - 1;
    if ( result > value ) {
        result = 0;
    }
    return result;
}

@implementation viXcode4

+ (void) load {
   NSLog(@"(viXcode4)");
}

+ (id)singleton {
    static viXcode4 *instance = nil;
    if (!instance) {
        instance = [[viXcode4 alloc] init];
    }
    return instance;
}

- (id)init {
    self = [super initWithWindowNibName:@"viXcode4Window" owner:self];
    if (self) {
        [self setWindowFrameAutosaveName:@"viXcode4Window"];
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
                                @"vi_12345789", @"1",
                                @"vi_12345789", @"2",
                                @"vi_12345789", @"3",
                                @"vi_12345789", @"4",
                                @"vi_12345789", @"5",
                                @"vi_12345789", @"6",
                                @"vi_12345789", @"7",
                                @"vi_12345789", @"8",
                                @"vi_12345789", @"9",
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
                                @"vi_w", @"w",
                                @"vi_b", @"b",
                                @"vi_B", @"B",
                                @"vi_u", @"u",
                                @"vi_U", @"U",
                                @"vi_o", @"o",
                                @"vi_O", @"O",
                                @"vi_i", @"i",
                                @"vi_a", @"a",
                                @"vi_d", @"d",
                                @"vi_p", @"p",
                                nil];

        mode1d_key2selector = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"vi_dd", @"d",
                                @"vi_dh", @"h",
                                @"vi_dk", @"k",
                                @"vi_dj", @"j",
                                @"vi_dl", @"l",
                                @"vi_dw", @"w",
                                @"vi_ddollar", @"$",
                                nil];

        mode1c_key2selector = [[NSDictionary alloc] initWithObjectsAndKeys:
                                @"vi_cw", @"w",
                                nil];
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

- (IBAction)acceptInput:(id)sender{
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

- (void)vi_x {
	[self showAction:@"(x) - Delete character"];
	[firstResponder deleteForward:self];
}

// FIXME These seem broken
- (void)vi_leftBrace {
	[self showAction:@"({) - Move to beginning of the previous paragraph"];
	// We have to move left until we hit the paragraph before we can issue the move call
	NSUInteger location = [firstResponder selectedRange].location;
	NSString* text = [[firstResponder textStorage] string];
	do {
        location = viXcode4_decrement( location );
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
	NSUInteger location = viXcode4_decrement( range.location );
	do {
		location = viXcode4_decrement( location );
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
	//mode = 3;
	//saveInput = YES;
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

    if ( [firstKey isEqualToString:@"c"] ) {
        [self selectorDispatch:mode1c_key2selector withKey:lastKey];
    }
    else if ( [firstKey isEqualToString:@"d"] ) {
        [self selectorDispatch:mode1d_key2selector withKey:lastKey];
    }
	
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
    //[firstResponder moveRight:self];
    [firstResponder setMark:self];
    while ( lineCount > 0 ) {
        lineCount--;
        [firstResponder moveUp:self];
    }
    [firstResponder moveToBeginningOfLine:self];
    [firstResponder deleteToMark:self];
}


//- (void)mode1_dl {
//    [self reflectAction:@"Vi: (dl) Delete multiple characters to the right"];
	
//    NSRange cR = [firstResponder selectedRange];
//    cR.length = mode1_repeat;
//    NSMutableString* mutstr = [[firstResponder textStorage] mutableString];
//    [mutstr deleteCharactersInRange:cR];
//    cR.length = 1;
//    [firstResponder setSelectedRange:cR];
//}

//- (void)mode1_ddollar {
//    [self reflectAction:@"Vi: (d$) Delete to end of current line"];
	
//    NSRange cR = [firstResponder selectedRange];
//    cR.length = 0;
//    [firstResponder setSelectedRange:cR];
//    [firstResponder deleteToEndOfLine:self];
//    cR.length = 1;
//    cR.location = (cR.location == 0) ? 0 : cR.location - 1 ;
//    [firstResponder setSelectedRange:cR];
//}


//[>* delete one or more words forward.  
// A bug was fixed in 0.2 that made sure to erase the whole word.
// A bug was fixed in 0.3.1 to only delete extra space after words, and not other characters.
// */
//- (void)mode1_dw {
//    [self reflectAction:[@"Vi: (dw) Delete Word " stringByAppendingString:[NSString stringWithFormat:@"%i", mode1_repeat]]];
//    int i;
//    NSRange cRange = [firstResponder selectedRange];
//    cRange.length = 0;
//    [firstResponder setSelectedRange:cRange];
//    for (i=0;i<mode1_repeat;i++)
//        [firstResponder deleteWordForward:self];
//    NSString* str = [[firstResponder textStorage] string];
//    unichar c = [str characterAtIndex:cRange.location];
//    if (isspace(c)) 
//    {
//        [firstResponder deleteForward:self];
//    }
//}

// TODO vi_g

- (void)dealloc {
    [super dealloc];
}

@end
