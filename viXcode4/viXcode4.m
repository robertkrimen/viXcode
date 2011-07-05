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
   NSLog(@"Hello, from viXcode4");
}

+ (id)singleton {
    static viXcode4 *instance = nil;
    if (!instance) {
        instance = [[viXcode4 alloc] init];
    }
    NSLog(@"Yield instance");
    return instance;
}

- (id)init {
    self = [super initWithWindowNibName:@"viXcode4Window" owner:self];
    if (self) {
        [self setWindowFrameAutosaveName:@"viXcode4Window"];
		[[self window] setDelegate:self];
		[[self window] setHasShadow:NO];
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

- (IBAction)__do__:(id)sender{
    NSLog(@"Yoink!");
	[self showWindowIfNeeded:sender];
}

- (void)dealloc {
    [super dealloc];
}

@end
