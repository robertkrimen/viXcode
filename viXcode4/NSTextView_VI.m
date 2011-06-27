// NSTextView_VI.m

#import "NSTextView_VI.h"

@implementation NSTextView (VI)

- (void)viXcode4_escape:(id)sender {
    NSLog(@"Derpity derp!");
    NSLog(@"%@", [[[NSApp mainWindow] firstResponder] class]);
    [[[NSApp mainWindow] firstResponder] moveToEndOfLine:sender];
    //[[ViCommandPanelController sharedViCommandPanelController] handleInputAction:self];
    return;
}

@end
