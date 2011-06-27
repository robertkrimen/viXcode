#import "ViCommandPanelController.h"

@implementation ViCommandPanelController

+ (id)sharedViCommandPanelController {
    static ViCommandPanelController *sharedInstance = nil;
    if (!sharedInstance) {
        sharedInstance = [[ViCommandPanelController alloc] init];
    }
    return sharedInstance;
}

- (id)init {
    self = [super initWithWindowNibName:@"ViCommandPanel" owner:self];
    if (self) {
        [self setWindowFrameAutosaveName:@"ViCommandPanel"];
		
		// ADDED by Jerome Duquennoy (2 Feb 07) ---------------------------
		[[self window] setDelegate:self];
		[[self window] setHasShadow:NO];
		//----------------------------------
		
		singleCharKeys = [NSArray arrayWithObjects:
						  @"{",
						  @"}",
						  @"^",
						  @":",
						  @"?",
						  @"/",
						  @"0",
						  @"1",
						  @"2",
						  @"3",
						  @"4",
						  @"5",
						  @"6",
						  @"7",
						  @"8",
						  @"9",
						  @"A",
						  @"c",
						  @"e",
						  @"E",
						  @"G",
						  @"I",
						  @"l",
						  @"n",
						  @"N",
						  @"h",
						  @"j",
						  @"J",
						  @"k",
						  @"r",
						  @"$",
						  @"_",
						  @"x",
						  @"w",
						  @"W",
						  @"b",
						  @"B",
						  @"u",
						  @"o",
						  @"O",
						  @"i",
						  @"a",
						  @"d",
						  @"p",
						  NULL];
		singleCharSels = [NSArray arrayWithObjects:
						  @"single_braceL",
						  @"single_braceR",
						  @"single_caret",
						  @"single_colon",
						  @"single_questionmark",
						  @"single_slash",
						  @"single_underscore",
						  @"single_digit",
						  @"single_digit",
						  @"single_digit",
						  @"single_digit",
						  @"single_digit",
						  @"single_digit",
						  @"single_digit",
						  @"single_digit",
						  @"single_digit",
						  @"single_A",
						  @"single_c",
						  @"single_e",
						  @"single_E",
						  @"single_G",
						  @"single_I",
						  @"single_l",
						  @"single_n",
						  @"single_N",
						  @"single_h",
						  @"single_j",
						  @"single_J",
						  @"single_k",
						  @"single_r",
						  @"single_dollar",
						  @"single_underscore",
						  @"single_x",
						  @"single_w",
						  @"single_w",
						  @"single_b",
						  @"single_B",
						  @"single_u",
						  @"single_o",
						  @"single_O",
						  @"single_i",
						  @"single_a",
						  @"single_d",
						  @"single_p",
						  NULL];
		singleDict = [NSDictionary dictionaryWithObjects:singleCharSels forKeys:singleCharKeys];
		[singleDict retain];  // i am pretty sure that we only need to retain the dictionary
		// But, my understanding of ObjC is very poor, so I could be wrong here.
		
		// we also create multiple dictionaries for the two-key mode1 input
		mode1Keys_d = [NSArray arrayWithObjects:
					   @"d",
					   @"h",
					   @"j",
					   @"k",
					   @"l",
					   @"w",
					   @"$",
					   NULL];
		mode1Sels_d = [NSArray arrayWithObjects:
					   @"mode1_dd",
					   @"mode1_dh",
					   @"mode1_dj",
					   @"mode1_dk",
					   @"mode1_dl",
					   @"mode1_dw",
					   @"mode1_ddollar",
					   NULL];
		
		mode1Dict_d = [NSDictionary dictionaryWithObjects:mode1Sels_d forKeys:mode1Keys_d];
		[mode1Dict_d retain];
		
		mode1Keys_c = [NSArray arrayWithObjects:
					   @"w",
					   NULL];
		mode1Sels_c = [NSArray arrayWithObjects:
					   @"mode1_cw",
					   NULL];
		
		mode1Dict_c = [NSDictionary dictionaryWithObjects:mode1Sels_c forKeys:mode1Keys_c];
		[mode1Dict_c retain];
		
		
		// these marshal out the second dictionary from the first key
		mode1Keys = [NSArray arrayWithObjects:
					 @"d",
					 @"c",
					 NULL];
		mode1Dicts = [NSArray arrayWithObjects:
					  mode1Dict_d,
					  mode1Dict_c,
					  NULL];
		mode1Dict = [NSDictionary dictionaryWithObjects:mode1Dicts forKeys:mode1Keys];
		[mode1Dict retain];
		
		
		lastSearchString = [NSMutableString stringWithCapacity:16];
		[lastSearchString retain];
		
	}
    return self;
}

- (void)dealloc {
    [super dealloc];
	[singleDict release];
}


- (void)windowDidLoad {
    [[self window] setTitle:NSLocalizedString(@"Vi Command", @"")];
    [super windowDidLoad];
}

- (void)showWindowIfNeeded:(id)sender;
{
    NSWindow *searchWindow = [self window];
    if(![searchWindow isVisible]) {
		
        // CHANGED  by Jerome Duquennoy (2 Feb 07) and Jason Corso (to change location on nonscrollview) ---------
        NSView *view = [sender enclosingScrollView];
        if (view == nil) view = sender;
        NSWindow *textFieldWindow = [view window];
        NSRect textFieldRect;
        NSPoint textFieldBottomLeft;
		NSRect  searchWindowFrame = [searchWindow frame];
		
		if ([view isKindOfClass:[NSScrollView class]])
		{
			textFieldRect = [view convertRect: [[(NSScrollView*)view contentView] frame] toView: nil];
			textFieldBottomLeft = NSMakePoint(textFieldRect.origin.x,
											  textFieldRect.origin.y);
			searchWindowFrame.origin = [textFieldWindow convertBaseToScreen: textFieldBottomLeft];
        }
		else
		{
			textFieldRect = [view convertRect: [view bounds] toView: nil];
			searchWindowFrame.origin = [textFieldWindow convertBaseToScreen: textFieldRect.origin];
			searchWindowFrame.origin.y -= searchWindowFrame.size.height;
		}
		
        searchWindowFrame.size.width = textFieldRect.size.width;
        
        [searchWindow setFrame:searchWindowFrame display:YES];
        //---------------------------------
    }
    [self showWindow:self];
	mode = 0;  // user hit the trigger key again...
}



- (IBAction)handleInputAction:(id)sender{
	[self showWindowIfNeeded: sender];
	[self doVi: sender];
}


- (IBAction)doVi:(id)sender {
	id targetWindow = [NSApp mainWindow];
    firstResponder = [targetWindow firstResponder];
	
	if ([firstResponder isKindOfClass:[NSTextView class]]) {
		cmdString = [textField stringValue];
		
		if ([cmdString length] < 1) {
			mode = 0;
			return;
		}
		
		locMod = 0;
		selLen = 1;
		saveCmdString = 0;
		
		// first, we check need to check the mode.  if it is a new entry (which will be most of the time)
		//  then we just create a single element substring corresponding to the key and find out what to do
		switch (mode)
		{
			case 0:
			{
				NSString* firstKey = [cmdString substringToIndex:1];
				
				NSString* selNSString = [singleDict objectForKey:firstKey];
				
				if (selNSString != nil)
				{
					SEL theSel = sel_getUid([selNSString UTF8String]);
					
					if (theSel != nil)
						[self performSelector:theSel];
				}
				
				if (!saveCmdString)
					[textField setStringValue:@""];
				
				NSRange cRange = [firstResponder selectedRange];
				
				cRange.location += locMod;
				if (cRange.location < 0)
					cRange.location = 0;
				cRange.length = selLen;
				
				[firstResponder setSelectedRange:cRange];
				[firstResponder scrollRangeToVisible:cRange];
			}
				break;
				// the d key was pressed first
			case 1:
			{
				[self handleMode1];
				
				if (!saveCmdString)
					[textField setStringValue:@""];
			}
				break;
				//  a search is in progress
			case 2:
			{
				saveCmdString=1;
				[self handleSearch:[cmdString substringFromIndex:1]];
				if (!saveCmdString)
					[textField setStringValue:@""];
			}
				break;
				// a number is being entered (only supported currently by ##G)
			case 3:
			{
				[self handleMode3];
				if (!saveCmdString)
					[textField setStringValue:@""];
			}
				break;
				// single character replacement mode
			case 4:
			{
				[self handleMode4];
				if (!saveCmdString)
					[textField setStringValue:@""];
			}
				break;
			case 5:
			{
				// For mode 5, nothing must be done except.  We are always building the command string.
				//  The return key handler will actually issue the "handle" command 
			}
				break;
		}
	}
}

// user hits enter in popup command window's text field.
- (void)textFieldAction:(id)sender {
	// function depends on mode
	switch (mode)
	{
		case 2:
			if (searchIsFromARepeat)
			{
				NSString* newCmdString;
				if (mode2_dirIsForward)
					newCmdString = [@"/" stringByAppendingString:lastSearchString];
				else
					newCmdString = [@"?" stringByAppendingString:lastSearchString];
				
				[textField setStringValue:newCmdString];
				
				[self doVi:self];
			}
			// when Vi terminates a search, it does not enter input mode...
			mode = 0;
			break;
			
			
		case 5:
			[self handleMode5];
			mode = 0;
			break;
			
			
		default:
			mode = 0;
			break;
	}
	
	// it appears we always want to do becuase the focus switches off to the desktop otherwise
	[[self window] makeFirstResponder: textField];
	// we always want to set the string value to zippo on enter...
	[textField setStringValue:@""];
}

- (void)controlTextDidChange:(NSNotification *)notification {
    [self doVi:self];
}


/** This is some testing code where I manually draw the cursor position as a frame rectangle
 * instead of relying on the selected range to draw the cursor position.  I'm not sure if it's
 * worth the extra overhead to do this type of rendering for the user.
 *
 *  I am not sure if this is the best way to represent the cursor since it requires manual drawing
 *  on the NSTextView and the rendered cursor does not blink as we are used to....
 *  The bigger issue is that I would need to erase the cursor I drew last time.  Currently the only way that I know
 *  how to do that would be to have the whole NSTextView redraw;  which is clearly a waste of computation.
 */
- (void)drawCursor {
	NSRange cR = [firstResponder selectedRange];
	//NSLog([NSString stringWithFormat:@"selection is %i,%i",cR.location,cR.length]);
	cR.length=1;
	unsigned pRectNo;
	NSRectArray rects = [[firstResponder layoutManager]
						 rectArrayForCharacterRange:cR
						 withinSelectedCharacterRange:cR
						 inTextContainer:[firstResponder textContainer]
						 rectCount:&pRectNo];
	
	//NSLog([NSString stringWithFormat:@"got %i rects",pRectNo]);
	NSGraphicsContext* theContext = [NSGraphicsContext currentContext];
	[theContext saveGraphicsState];
	
	NSRect frameRect = [firstResponder frame];
	[[NSColor orangeColor] setFill];
	int i;
	for (i=0;i<pRectNo;i++)
	{
		//	NSLog([NSString stringWithFormat:@"rect %i is %f,%f %f,%f",i,rects[i].origin.x,rects[i].origin.y,
		//	                                            rects[i].size.width,rects[i].size.height]);
		rects[i].origin.y = frameRect.size.height-rects[i].origin.y-rects[i].size.height;
		NSFrameRectWithWidth(rects[i],1);
		[firstResponder setNeedsDisplayInRect:rects[i] avoidAdditionalLayout:YES];
	}
	[theContext restoreGraphicsState];
}


- (void)reflectAction:(NSString*)msg {
	[[self window] setTitle:msg];
}


- (int)getIndexForLineNumber:(int)number ofString: (NSString*)string 
{
	unsigned numberOfLines, index, stringLength = [string length];
	
	if (number == 1)
		return 0;
	
	for (index = 0, numberOfLines = 1; (index < stringLength) && (numberOfLines < number); numberOfLines++)
	{	
		index = NSMaxRange([string lineRangeForRange:NSMakeRange(index, 0)]);
	}
	
	return index;
}



///  Beginning Single Item Definitions


- (void)single_braceL {
	[self reflectAction:@"Vi: ({) Beginning of Prev Paragraph"];
	// we have to move left until we hit the paragraph before we can issue the move call
	int loc = [firstResponder selectedRange].location;
	NSString* theText = [[firstResponder textStorage] string];
	do 
	{
		loc--;
		if (loc < 0)
		{ 
			loc=0;
			break;
		}
	} while (isspace([theText characterAtIndex:loc]));
	
	NSRange nR = NSMakeRange(loc,1);
	[firstResponder setSelectedRange:nR];
	[firstResponder moveToBeginningOfParagraph:self];
}

- (void)single_braceR {
	[self reflectAction:@"Vi: (}) Beginning of Next Paragraph"];
	[firstResponder moveRight:self];
	[firstResponder moveToEndOfParagraph:self];
	[firstResponder moveRight:self];
}


- (void)single_caret {
	[self reflectAction:@"Vi: (^) First non-Blank Character"];
	[firstResponder moveToBeginningOfLine:self];
	// now, move to the right until we hit a character
	int loc = [firstResponder selectedRange].location;
	NSString* theText = [[firstResponder textStorage] string];
	while (isspace([theText characterAtIndex:loc]))
	{
		loc++;
		if (loc >= [theText length])
		{ 
			loc=[theText length]-1;
			break;
		}
	} 
	NSRange nR = NSMakeRange(loc,1);
	[firstResponder setSelectedRange:nR];
}


/** enter into ex-style command buffer mode */
- (void)single_colon {
	[self reflectAction:@"Vi: (:) Ex command mode "];
	mode = 5;
	saveCmdString = 1;
}


- (void)single_digit {
	[self reflectAction:@"Vi: (#) Build number "];
	mode = 3;
	saveCmdString = 1;
}


- (void)single_dollar {
	[self reflectAction:@"Vi: ($) End Of Line"];
	[firstResponder moveToEndOfLine:self];
	locMod = -1;
}


//  this is kick of the forward searching capability
- (void)single_questionmark {
	[self reflectAction:@"Vi: (?) Reverse Search"];
	mode = 2;
	mode2_dirIsForward = NO;
	searchIsFirstTime = YES;
	saveCmdString=1;
	searchIsFromARepeat = NO;
	// we need to indicate if there was a past search to repeat (in the dark)
	if (![lastSearchString isEqualToString:@""]) {
		searchIsFromARepeat = YES;
	}
	else // only set the searchwrapping off if its new, else just keep its value
		searchIsWrapping = NO;
}

//  this is kick of the forward searching capability
- (void)single_slash {
	[self reflectAction:@"Vi: (/) Forward Search"];
	mode = 2;
	mode2_dirIsForward = YES;
	searchIsFirstTime = YES;
	saveCmdString=1;
	searchIsFromARepeat = NO;
	// we need to indicate if there was a past search to repeat (in the dark)
	if (![lastSearchString isEqualToString:@""]) {
		searchIsFromARepeat = YES;
	} 
	else // only set the searchwrapping off if its new, else just keep its value
		searchIsWrapping = NO;
}

- (void)single_underscore {
	[self reflectAction:@"Vi: (_) Beginning Of Line"];
	[firstResponder moveToBeginningOfLine:self];
}

// Insert at the end of the current line.  
// Question: Should we handle this compatible Vi mode...or consider wrapped lines, wrapped
- (void)single_A {
	[self reflectAction:@"Vi: (A) Insert at end of line"];
	[firstResponder moveToEndOfLine:self];
    [[self window] orderOut:self];
	selLen = 0;
}

- (void)single_a {
	[self reflectAction:@"Vi: (a) Insert Right"];
	[firstResponder moveRight:self];
	[[self window] orderOut:self];
	selLen = 0;
}

- (void)single_b {
	[self reflectAction:@"Vi: (b) Move Word Left"];
	[firstResponder moveWordLeft:self];
}


- (void)single_c {
	[self reflectAction:@"Vi: (c) Change Word --multi-- "];
	mode = 1;
	saveCmdString = 1;
}

- (void)single_d {
	[self reflectAction:@"Vi: (d) Delete --multi-- "];
	mode = 1;
	saveCmdString = 1;
}

- (void)single_e {
	[self reflectAction:@"Vi: (e) Move To End Of Word"];
	
	// CTS has not end of word motion
	// We will move to the Word on the right, and then roll backwards
	
	NSRange curRange = [firstResponder selectedRange];
	NSTextStorage* curTextStorage = [firstResponder textStorage];
	
	// if we are at the end of the buffer, just return
	if (curRange.location + 1 >= [curTextStorage length])
		return;
	
	NSString* theText = [curTextStorage string];
	
	[firstResponder moveWordRight:self];
	[firstResponder moveRight:self];  // cocoa just moves to the space end of the current word
	//  but vi moves to the beginning of the next word...
	
	// begin the rolling backwords
	// basically, continue to move backwords until it's an alpha or a number
	curRange = [firstResponder selectedRange];
	int loc = curRange.location - 1;
	do 
	{
		loc--;
	} while (!(isalpha([theText characterAtIndex:loc]) || isalpha([theText characterAtIndex:loc]) ));
	locMod = loc - curRange.location;
}


- (void)single_G {
	[self reflectAction:@"Vi: (G) Move to last line"];
	[firstResponder moveToEndOfDocument:self];
	[firstResponder moveToBeginningOfLine:self];
}


- (void)single_h {
	[self reflectAction:@"Vi: (h) Left"];
	[firstResponder moveLeft:self];
	locMod = -1;
}

- (void)single_I {
	[self reflectAction:@"Vi: (I) Insert at Beginning of Line"];
	[firstResponder moveToBeginningOfLine:self];
	[[self window] orderOut:self];
	selLen = 0;
}

- (void)single_i {
	[self reflectAction:@"Vi: (i) Insert"];
	[[self window] orderOut:self];
	selLen = 0;
}

- (void)single_j {
	[self reflectAction:@"Vi: (j) Down"];
	[firstResponder moveDown:self];
}


- (void)single_J {
	[self reflectAction:@"Vi: (J) Join next line with current"];
	
}


- (void)single_k {
	[self reflectAction:@"Vi: (k) Up"];
	[firstResponder moveUp:self];
}

- (void)single_l {
	[self reflectAction:@"Vi: (l) Right"];
	[firstResponder moveRight:self];	
}


// repeat the last search in the same direction
- (void)single_n {
	searchIsFirstTime = YES;
	[self handleSearch:lastSearchString];
	mode = 0;
}


// repeat the last search in the opposite direction
- (void)single_N {
	BOOL dirStack = mode2_dirIsForward;
	if (mode2_dirIsForward == YES)
		mode2_dirIsForward = NO;
	else
		mode2_dirIsForward = YES;
	
	searchIsFirstTime = YES;
	[self handleSearch:lastSearchString];
	mode = 0;
	
	mode2_dirIsForward = dirStack;
}


- (void)single_o {
	[self reflectAction:@"Vi: (o) Insert At New Line"];
	[firstResponder moveToEndOfLine:self];
	[firstResponder insertNewlineIgnoringFieldEditor:self];
	// wrapping causes some problem here.  We now have to check if there is an
	//  alpha character underneath the cursor (in the case of wrapping).  And
	//  and if there is, we need to insert a second newline character
	NSRange cRange = [firstResponder selectedRange];
	NSString* theText = [[firstResponder textStorage] string];
	if (!isspace([theText characterAtIndex:cRange.location]))
	{
		[firstResponder insertNewlineIgnoringFieldEditor:self];
		[firstResponder moveUp:self];
	}
	[[self window] orderOut:self];
	selLen = 0;
}


- (void)single_O {
	[self reflectAction:@"Vi: (O) Insert New Line Above"];
	NSRange cR = [firstResponder selectedRange];
	[firstResponder moveUp:self];
	NSRange nR = [firstResponder selectedRange];
	if (cR.location == nR.location)
	{
		[firstResponder moveToBeginningOfLine:self];
		[firstResponder insertNewlineIgnoringFieldEditor:self];
		[firstResponder moveUp:self];
		[[self window] orderOut:self];
		selLen = 0;	
		return;
	}
	
	[firstResponder moveToEndOfLine:self];
	[firstResponder insertNewlineIgnoringFieldEditor:self];
	// wrapping causes some problem here.  We now have to check if there is an
	//  alpha character underneath the cursor (in the case of wrapping).  And
	//  and if there is, we need to insert a second newline character
	NSRange cRange = [firstResponder selectedRange];
	NSString* theText = [[firstResponder textStorage] string];
	if (!isspace([theText characterAtIndex:cRange.location]))
	{
		[firstResponder insertNewlineIgnoringFieldEditor:self];
		[firstResponder moveUp:self];
	}
	[[self window] orderOut:self];
	selLen = 0;
}



// Put the kill buffer back into the text.  
// Changed in 0.2 to set the selection range to 0 because it was replacing the currently selected
//  character (I currently render the moving cursor as a selection in the NSTextField).
// This does not fix it.  ???  I may have to manage my own delete buffers....
- (void)single_p {
	[self reflectAction:@"Vi: (p) Put Kill Buffer Back "];
	// Wrapped text causes problems here.  Need to figure a good way to handle wrapped text.
	// Perhaps the solution is to add newlines in the beginning and end of a deleted line of text
    [firstResponder moveDown:self];
	NSRange cR = [firstResponder selectedRange];
	cR.length = 0;
	[firstResponder setSelectedRange:cR];
	[firstResponder yank:self];
}



/* start a single character replacement...mode 4 */
- (void)single_r {	
	[self reflectAction:@"Vi: (r) Single character replacement "];
	mode = 4;
	saveCmdString = 1;
}



- (void)single_u {
	[self reflectAction:@"Vi: (u) Undo"];
	NSUndoManager* undoMgr = [firstResponder undoManager];
	[undoMgr undo];
}

- (void)single_w {
	[self reflectAction:@"Vi: (w) Move Word Right"];
	
	NSRange curRange = [firstResponder selectedRange];
	NSTextStorage* curTextStorage = [firstResponder textStorage];
	
	
	// if we are at the end of the buffer, just return
	if (curRange.location + 1 >= [curTextStorage length])
		return;
	
	// it appears that the cocoa text system fails to move forward if the word is a 
	//  single character;  like a.  So, let's go and check if this is the case.
	if (isspace([[curTextStorage string] characterAtIndex:(curRange.location+1)]))
	{
		[firstResponder moveRight:self];
		NSString* theText = [curTextStorage string];
		// continue moving right while we are still space
		int loc = curRange.location+1;
		while (isspace([theText characterAtIndex:loc]))
		{
			[firstResponder moveRight:self];
			loc++;
			if (loc >= [curTextStorage length])
				return;
		}
	} 
	else
	{
	    [firstResponder moveWordRight:self];
		[firstResponder moveRight:self];  // cocoa just moves to the end of the current word
		//  but vi moves to the beginning of the next word...
	}
	
}

- (void)single_x {
	[self reflectAction:@"Vi: (x) Delete Character"];
	[firstResponder deleteForward:self];
}






- (void)handleMode1 {
	
	int len = [cmdString length];
	
	// first thing is a sanity check
	//  the cmdString should be 2 or more characters long
	if (len < 2)
	{
		// try to gracefully recover
		[textField setStringValue:@""];
		mode = 0;
		return;
	}
	
	// second thing to do is to see if the last character of the cmdString is a number
	//  if it is a number, then we just drop out and let the user continue typing
	unichar c = [cmdString characterAtIndex:(len-1)];
	if (isdigit(c)) 
	{
		saveCmdString=1;
		return;
	}
	
	NSString* firstKey = [cmdString substringToIndex:1];
	NSString* lastKey = [cmdString substringFromIndex:(len-1)];
	mode1_repeat = 1;
	if (len > 2)
	{
		NSRange numRange = NSMakeRange(1,len-2);
		NSString* numStr = [cmdString substringWithRange:numRange];
		mode1_repeat = [numStr intValue];
	}
	
	// now we have to get the function to actually call!
	NSDictionary* secondDict = [mode1Dict objectForKey:firstKey];
	
	if (secondDict != nil)
	{
		NSString* selNSString = [secondDict objectForKey:lastKey];
		if (selNSString != nil)
		{
			SEL theSel = sel_getUid([selNSString UTF8String]);
			
			if (theSel != nil) 
			{
				[self performSelector:theSel];
				
				// only do these if we actually did some operation
				NSRange cRange = [firstResponder selectedRange];
				
				cRange.location += locMod;
				if (cRange.location < 0)
					cRange.location = 0;
				cRange.length = selLen;
				
				[firstResponder setSelectedRange:cRange];
				[firstResponder scrollRangeToVisible:cRange];	
			}
		}
	}
	
	// clean up is the same for any of the fall-outs too
	mode = 0;
}


/** change one or more words forward.  A bug was fixed in 0.2 that made sure to erase the whole word */
- (void)mode1_cw {
	[self reflectAction:[@"Vi: (cw) Change Word " stringByAppendingString:[NSString stringWithFormat:@"%i", mode1_repeat]]];
	int i;
	NSRange cRange = [firstResponder selectedRange];
	cRange.length = 0;
	[firstResponder setSelectedRange:cRange];
	for (i=0;i<mode1_repeat;i++)
		[firstResponder deleteWordForward:self];
	[[self window] orderOut:self];
	selLen = 0;
}


/** delete one or more lines forward(down).  Fixed a bug in 0.2 -- changed it to use a mark because there
 *  was unexpected behavior using the deleteToEndOfLine method
 */
- (void)mode1_dd {
	[self reflectAction:@"Vi: (dd) Delete Lines "];
	int i;
	
	[firstResponder moveToBeginningOfLine:self];
	// if user tries to delete more lines below the end of the doc...will actually delete up in this code...
	int numLinesMovedDown=0;	
	for (i=0;i<mode1_repeat;i++)
	{
		NSRange cP = [firstResponder selectedRange];
		[firstResponder moveDown:self];
		NSRange nP = [firstResponder selectedRange];
		if (cP.location == nP.location)
			break;
		numLinesMovedDown++;
	}
	[firstResponder setMark:self];
	for (i=0;i<numLinesMovedDown;i++)
	{
		[firstResponder moveUp:self];
	}
	[firstResponder deleteToMark:self];
}


/* Are there adv/disadv to deleting parts of the text through the setMark/DeleteToMark versu
 *  manually constructing the range and then deleteCharactersInRange?
 */
- (void)mode1_dh {
	[self reflectAction:@"Vi: (dh) Delete multiple characters to the left"];
	[firstResponder moveLeft:self];
	[firstResponder setMark:self];
	int i;
	for (i=0;i<mode1_repeat;i++)
		[firstResponder moveLeft:self];
	[firstResponder deleteToMark:self];
}


/* differs from dd in that it deletes from the current character location */
- (void)mode1_dj {
	[self reflectAction:@"Vi: (dj) Delete lines down "];
	int i;
	
	// if user tries to delete more lines below the end of the doc...will actually delete up in this code...
	int numLinesMovedDown=0;	
	for (i=0;i<mode1_repeat;i++)
	{
		NSRange cP = [firstResponder selectedRange];
		[firstResponder moveDown:self];
		NSRange nP = [firstResponder selectedRange];
		if (cP.location == nP.location)
			break;
		numLinesMovedDown++;
	}
	[firstResponder setMark:self];
	for (i=0;i<numLinesMovedDown;i++)
	{
		[firstResponder moveUp:self];
	}
	[firstResponder deleteToMark:self];
}


- (void)mode1_dk {
	[self reflectAction:@"Vi: (dk) Delete multiple lines up"];
	int i;
	[firstResponder moveLeft:self];
	[firstResponder setMark:self];
	for (i=0;i<mode1_repeat;i++)
	{
		[firstResponder moveUp:self];
	}
	[firstResponder deleteToMark:self];
}


- (void)mode1_dl {
	[self reflectAction:@"Vi: (dl) Delete multiple characters to the right"];
	
	NSRange cR = [firstResponder selectedRange];
	cR.length = mode1_repeat;
	NSMutableString* mutstr = [[firstResponder textStorage] mutableString];
	[mutstr deleteCharactersInRange:cR];
	cR.length = 1;
	[firstResponder setSelectedRange:cR];
}

- (void)mode1_ddollar {
	[self reflectAction:@"Vi: (d$) Delete to end of current line"];
	
	NSRange cR = [firstResponder selectedRange];
    cR.length = 0;
	[firstResponder setSelectedRange:cR];
	[firstResponder deleteToEndOfLine:self];
	cR.length = 1;
	cR.location = (cR.location == 0) ? 0 : cR.location - 1 ;
	[firstResponder setSelectedRange:cR];
}


/** delete one or more words forward.  
 A bug was fixed in 0.2 that made sure to erase the whole word.
 A bug was fixed in 0.3.1 to only delete extra space after words, and not other characters.
 */
- (void)mode1_dw {
	[self reflectAction:[@"Vi: (dw) Delete Word " stringByAppendingString:[NSString stringWithFormat:@"%i", mode1_repeat]]];
	int i;
	NSRange cRange = [firstResponder selectedRange];
	cRange.length = 0;
	[firstResponder setSelectedRange:cRange];
	for (i=0;i<mode1_repeat;i++)
		[firstResponder deleteWordForward:self];
	NSString* str = [[firstResponder textStorage] string];
	unichar c = [str characterAtIndex:cRange.location];
	if (isspace(c)) 
	{
		[firstResponder deleteForward:self];
	}
}



/// handle mode 2 (SEARCHING)

- (void)handleSearch:(NSString*)searchString {
	NSRange range;
	NSString *title = nil;
	NSString *string = [firstResponder string];
	int textLen = [[firstResponder textStorage] length];
	
	// always turn this off here?
	searchIsFromARepeat = NO;
	
	[lastSearchString setString:searchString];
	int options = 0;
	
	if(!mode2_dirIsForward)
		options |= NSBackwardsSearch;
	
	if ([searchString rangeOfCharacterFromSet:[NSCharacterSet uppercaseLetterCharacterSet]].location == NSNotFound) {
		options |= NSCaseInsensitiveSearch;
	}
	
	/* the search I am implementing right now has no "fromCmd" functionality, could be added by ctrl-/ to move ahead
	 and make it a real incremental search
	 if(searchIsfromCmd && !searchIsWrapping){
	 // the second successive search of the same string should start searching past the end of the first hit
	 if(mode2_dirIsForward)
	 currentRange.location = selectedRange.location + selectedRange.length;
	 else
	 currentRange.length = selectedRange.location;
	 }
	 */
	NSRange selectedRange = [firstResponder selectedRange];
	
	// guarantee that we're always searching to the extent of the range we want.
	if(mode2_dirIsForward)
	{
		if (searchIsFirstTime)
			mode2_currentRange.location = [firstResponder selectedRange].location + 1;
		mode2_currentRange.length = textLen - mode2_currentRange.location; // we're always searching to the end of the view.
	}
	else
	{
		mode2_currentRange.location = 0;
		if (searchIsFirstTime)
			mode2_currentRange.length = selectedRange.location;
	}
	
	if(searchIsWrapping){
		mode2_currentRange = NSMakeRange(0,textLen);
	}
	
	
	range = [string rangeOfString:searchString
						  options:options
							range:mode2_currentRange];
	
	
	if (range.location == NSNotFound){
		if(!searchIsFirstTime) NSBeep();
		
		title = [NSString stringWithFormat:NSLocalizedString(@"Vi: Failing %@I-Search", @""), 
				 (searchIsWrapping ? NSLocalizedString(@"wrapped ", @"") : @"")];
		
		if(!mode2_dirIsForward) title = [title stringByAppendingString:NSLocalizedString(@" backward",@"")];
		
		searchIsWrapping = YES;
		[[self window] setTitle:title];
		return;
	}else{
		if(mode2_dirIsForward){
			mode2_currentRange = NSMakeRange(range.location, (textLen - range.location));
		}else{
			// do nothing
		}
		title = [NSString stringWithFormat:NSLocalizedString(@"Vi: %@I-Search", @""),
				 (searchIsWrapping ? @"Wrapped " : @"")];
		
		if(!mode2_dirIsForward) title = [title stringByAppendingString:NSLocalizedString(@" backward",@"")];
		
		searchIsFirstTime = NO;
		searchIsWrapping = NO;
		[self  reflectAction:title];
	}
	
	[firstResponder setSelectedRange:range];
	[firstResponder scrollRangeToVisible:range];
	
	
}




- (void)handleMode3 {
	
	int len = [cmdString length];
	
	// first thing is a sanity check
	//  the cmdString should be 2 or more characters long
	if (len < 2)
	{
		// try to gracefully recover
		[textField setStringValue:@""];
		mode = 0;
		return;
	}
	
	// second thing to do is to see if the last character of the cmdString is a number
	//  if it is a number, then we just drop out and let the user continue typing
	unichar c = [cmdString characterAtIndex:(len-1)];
	if (isdigit(c)) 
	{
		saveCmdString=1;
		return;
	}
	
	
	NSString* lastKey = [cmdString substringFromIndex:(len-1)];
	if ([lastKey isEqualToString:@"G"])
	{
	    NSRange numRange = NSMakeRange(0,len-1);
		NSString* numStr = [cmdString substringWithRange:numRange];
		int lineNo = [numStr intValue];
		[self reflectAction:[NSString stringWithFormat:@"Vi: (G) Moving to line %i",lineNo]];
		
		
		int index = [self getIndexForLineNumber:lineNo 
									   ofString:[firstResponder string]];
		
		NSRange cR = NSMakeRange(index,1);
		[firstResponder setSelectedRange:cR];
	}
	else
		NSBeep();
	
	// clean up is the same for any of the fall-outs too
	saveCmdString=0;
	mode = 0;
	
}





- (void)handleMode4 {
	
	int len = [cmdString length];
	
	// first thing is a sanity check
	//  the cmdString should be 2 characters long
	if (len != 2)
	{
		// try to gracefully recover
		[textField setStringValue:@""];
		saveCmdString = 0;
		mode = 0;
		return;
	}
	
	NSRange cR = [firstResponder selectedRange];
	cR.length = 1;
	NSString* newStr = [cmdString substringFromIndex:(len-1)];
	[firstResponder replaceCharactersInRange:cR withString:newStr];
	[firstResponder setSelectedRange:cR];
	
	saveCmdString = 0;
	mode = 0;
}



/** This message is issued only when the cmd string is complete (and user hits enter) 
 *  The commands are handled by issuing mnemonics to the program.  This has potential pitfalls,
 *  but since there are no applications hooks, I think it may be the only way to doing it.
 */
- (void)handleMode5 {
	
	NSDate* now;
	NSWindow* win;
	NSEvent* e;
	int len = [cmdString length];
	
	// then we don't have to do anything
	if (len < 2)
		return;
	
	// otherwise, let's check the second character to see what we should do
	unichar c = [cmdString characterAtIndex:1];
	switch (c)
	{
		case 'w':
			now = [NSDate date]; 
			win = [firstResponder window];
			e = [NSEvent keyEventWithType:NSKeyDown
								 location:NSMakePoint(0,0)
							modifierFlags:NSCommandKeyMask
								timestamp:[now timeIntervalSinceNow]
							 windowNumber:[win windowNumber]
								  context:[win graphicsContext]
							   characters:@"@s"
			  charactersIgnoringModifiers:@"s"
								isARepeat:NO
								  keyCode:0x1];
			[win postEvent:e atStart:NO];
			break;
	}
	
}

// ADDED  by Jerome Duquennoy (2 Feb 07) ---------------------------
- (void)windowDidResignKey:(NSNotification*)notification
{
	[textField setStringValue:@""];
	[[self window] close];
}
//----------------------------------
@end
