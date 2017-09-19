//
//  IMOBIAPHelper.m
//  IMOB
//
//  Created by Jeff Janes on 5/21/13.
//  Copyright (c) 2013 I-mobilize.com. All rights reserved.
//

#import "IMOBIAPHelper.h"

@implementation IMOBIAPHelper

+ (IMOBIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static IMOBIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.quix.ufuk.new", //@"com.ufuk.quix.second"/*, @"com.hayden.swipe500", @"com.hayden.swipe1000"*/,
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end