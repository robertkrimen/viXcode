/* NSTextView_VI.h
 
 Written 2006-2009, Jason Corso
 Based on original code for I-Search Written 2004, Michael McCracken
 
 This adds actions to NSTextView that invoke
 the Vi Command controller.
 
 Use the ~/Library/KeyBindings/DefaultKeyBinding.dict file
 to set up keybindings. I suggest mapping the escape key: "\U001B" = "VI_escapeMode:";
 
 
 This work is licensed under the Creative Commons Attribution-ShareAlike License. 
 To view a copy of this license, visit http://creativecommons.org/licenses/by-sa/1.0/ 
 or send a letter to Creative Commons, 559 Nathan Abbott Way, Stanford, California 94305, USA.
 
 */

#import <AppKit/AppKit.h>

@interface NSTextView (VI)
- (void)VI_escapeMode:(id)sender;
@end
