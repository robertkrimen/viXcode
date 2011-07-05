//
//  viXcode4.h
//  viXcode4
//
//  Created by Broken Rim on 6/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface viXcode4 : NSWindowController <NSWindowDelegate> {
@private
    
}

+ (id)singleton;
- (IBAction)do:(id)sender;

@end
