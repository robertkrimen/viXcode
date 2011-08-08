// NSTextView_VI.m

#import "NSTextView_VI.h"
#import "viXcode.h"

@implementation NSTextView (VI)

- (void)viXcode_Open:(id)sender {
    NSLog(@"%@", [[[NSApp mainWindow] firstResponder] class]);
    [[viXcode singleton] open:self];
}

@end
