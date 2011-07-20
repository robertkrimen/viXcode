//
//  viXcode4.m
//  viXcode4
//
//  Created by Broken Rim on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "viXcode4.h"

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
                                @"vi_o", @"o",
                                @"vi_O", @"O",
                                @"vi_i", @"i",
                                @"vi_a", @"a",
                                @"vi_d", @"d",
                                @"vi_p", @"p",
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
			textFieldBottomLeft = NSMakePoint(textFieldRect.origin.x,
											  textFieldRect.origin.y);
			searchWindowFrame.origin = [textFieldWindow convertBaseToScreen: textFieldBottomLeft];
        }
        else {
			textFieldRect = [view convertRect: [view bounds] toView: nil];
			searchWindowFrame.origin = [textFieldWindow convertBaseToScreen: textFieldRect.origin];
			searchWindowFrame.origin.y -= searchWindowFrame.size.height;
		}
		
        searchWindowFrame.size.width = textFieldRect.size.width;
        
        [searchWindow setFrame:searchWindowFrame display:YES];
    }
    [self showWindow:self];
	// mode = 0;
}

- (IBAction)acceptInput:(id)sender{
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
		inputSoFar = [textField stringValue];
		
        NSLog(@"inputSoFar: %@", inputSoFar);

		if ([inputSoFar length] < 1) {
			mode = 0;
			return;
		}

		locationShift = 0;
		selectionSize = 1;
		saveInputSoFar = NO;

		switch (mode) {
			case 0: {
				NSString* firstKey = [inputSoFar substringToIndex:1];
				NSString* selectorName = [mode0_key2selector objectForKey:firstKey];
				
                NSLog(@"selectorName: %@", selectorName);
				if (selectorName != nil) {
					SEL selector_ = sel_registerName([selectorName UTF8String]);
                    if (selector_ && [self respondsToSelector:selector_]) {
						[self performSelector:selector_];
                    }
				}
				
				if (!saveInputSoFar) 
					[textField setStringValue:@""];
				
				NSRange cRange = [firstResponder selectedRange];
				
				cRange.location += locationShift;
				cRange.length = selectionSize;
				
				[firstResponder setSelectedRange:cRange];
				[firstResponder scrollRangeToVisible:cRange];
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

- (void)dealloc {
    [super dealloc];
}

@end
