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
    return instance;
}

- (id)init {
    self = [super initWithWindowNibName:@"viXcode4_Window" owner:self];
    if (self) {
        [self setWindowFrameAutosaveName:@"viXcode4_Window"];
		[[self window] setDelegate:self];
		[[self window] setHasShadow:NO];
    }
    
    return self;
}

- (IBAction)do:(id)sender{
	[self showWindow:self];
}

- (void)dealloc {
    [super dealloc];
}

@end
