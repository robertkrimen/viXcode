// NSTextView_VI.m

#import "NSTextView_VI.h"
#import "viXcode4.h"

@implementation NSTextView (VI)

- (void)viXcode4_escape:(id)sender {
    NSLog(@"Derpity derp!");
    NSLog(@"%@", [[[NSApp mainWindow] firstResponder] class]);
    [[[NSApp mainWindow] firstResponder] moveToEndOfLine:sender];
    [[viXcode4 singleton] __do__:self];
    //[[ViCommandPanelController sharedViCommandPanelController] handleInputAction:self];
    return;
}

@end
