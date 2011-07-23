//
//  viXcode4.h
//  viXcode4
//
//  Created by Broken Rim on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ctype.h>

@interface viXcode4 : NSWindowController <NSWindowDelegate> {
    IBOutlet NSTextField *textField;
@private
	id firstResponder;

	/**
     *  The mode manages how to handle the character input
	 *  0 -- Single character, normal, initial, default mode
	 *  1 -- Multiple character input initiated by a "d"
	 *  2 -- Searching mode (implementing using an integrated McCracken's incremental search (bless open source))
	 *  3 -- A number was entered first... and we'll construct the number and then process what follows
	 *  4 -- Single character replacement
	 *  5 -- Some support for ex-style ":" commands (like ":w")
	 */
	int mode;
	NSInteger locationShift;
	NSUInteger selectionSize;
	NSString *inputSoFar;
	BOOL saveInputSoFar;

	NSDictionary* mode0_key2selector;
}

+ (id)singleton;

- (IBAction)acceptInput:(id)sender;
- (IBAction)keyPressed:(id)sender;
- (IBAction)textFieldAction:(id)sender;

@end
