//
//  viXcodeTest.m
//  viXcodeTest
//
//  Created by Broken Rim on 8/19/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "viXcodeTest.h"
#import "NSTextView_VI.h"
#import "viXcode.h"

@implementation viXcodeTest

- (void)setUp
{
    [super setUp];
    NSBundle * myBundle = [NSBundle bundleForClass: [self class]];
    NSString * bundlePath = [myBundle pathForResource: @"viXcode" ofType: @"bundle"];
    NSBundle * bundleToLoad = [NSBundle bundleWithPath: bundlePath];
    NSAssert(bundleToLoad != nil, @"bundleToLoad !nil");
    [bundleToLoad load];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testExample
{
    NSTextView *textView = [[NSTextView alloc] init];
    STAssertNotNil(textView, @"testView !nil");
    [textView viXcode_Open:nil];
    [[viXcode singleton] vi_gg];
    //STFail(@"Unit tests are not implemented yet in viXcodeTest");
}

@end
