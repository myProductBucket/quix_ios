//
//  NSString+Utility.m
//  Quix
//
//  Created by Xiao Ming Liu on 15/1/2016.
//  Copyright © 2016 self. All rights reserved.
//

#import "NSString+Utility.h"

@implementation NSString (Utility)
- (BOOL)checkText {//check the Quiz Name and Time in ModalEffectView
    NSString *rawString = self;
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    if ([trimmed length] == 0) {
        // Text was empty or only whitespace.
        
        return NO;
    }
    return YES;
}
@end
