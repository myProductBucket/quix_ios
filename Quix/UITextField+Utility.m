//
//  UITextField+Utility.m
//  Quix
//
//  Created by Matti Heikkinen on 12/27/15.
//  Copyright © 2015 self. All rights reserved.
//

#import "UITextField+Utility.h"

@implementation UITextField (Utility)
- (BOOL)checkText: (UITextField *)text {//check the Quiz Name and Time in ModalEffectView
    NSString *rawString = [text text];
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *trimmed = [rawString stringByTrimmingCharactersInSet:whitespace];
    if ([trimmed length] == 0) {
        // Text was empty or only whitespace.
        
        return NO;
    }
    return YES;
}

@end
