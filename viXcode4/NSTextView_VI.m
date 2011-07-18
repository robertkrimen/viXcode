// NSTextView_VI.m

#import "NSTextView_VI.h"
#import "viXcode4.h"

@implementation NSTextView (VI)

- (void)viXcode4_escape:(id)sender {
    //NSLog(@"%@", [[[NSApp mainWindow] firstResponder] class]);
    [[viXcode4 singleton] acceptInput:self];
}

@end
