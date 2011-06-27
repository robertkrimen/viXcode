// NSTextView_VI.m

#import "NSTextView_VI.h"
#import "ViCommandPanelController.h"

@implementation NSTextView (VI)

- (void)VI_escapeMode:(id)sender {
    [[ViCommandPanelController sharedViCommandPanelController] handleInputAction:self];
    return;
}

@end
