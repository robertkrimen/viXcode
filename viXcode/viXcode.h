//
//  viXcode.h
//  viXcode
//
//  Created by Broken Rim on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <ctype.h>

@interface viXcode : NSWindowController <NSWindowDelegate> {
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
	NSInteger mode;

	NSInteger mode1_repeatCount;

    BOOL searchForward;
    BOOL searchInitial;
    BOOL searchRepeat;
    BOOL searchWrap;
	NSRange searchRange;
	NSMutableString* lastSearchTarget;

	NSInteger locationShift;
	NSUInteger selectionSize;

	NSString *input;
	BOOL saveInput;

	NSDictionary* mode0_key2selector;
	NSDictionary* mode1d_key2selector;
	NSDictionary* mode1c_key2selector;
}

+ (id)singleton;

- (IBAction)open:(id)sender;
- (IBAction)keyPressed:(id)sender;
- (IBAction)textFieldAction:(id)sender;
- (void)selectorDispatch:(NSDictionary *)key2selector  withKey:(NSString *)key;
- (void)handleMode1;
- (void)handleSearch:(NSString *)searchTarget;
- (void)handleMode3;

@end
