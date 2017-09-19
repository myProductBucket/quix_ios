//
//  NSArray+RJSON.m
//  Quix
//
//  Created by Matti Heikkinen on 12/24/15.
//  Copyright © 2015 self. All rights reserved.
//

#import "NSArray+RJSON.h"

@implementation NSArray (RJSON)

- (NSString *)rj_jsonStringWithPrettyPrint:(BOOL)prettyPrint
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:(NSJSONWritingOptions) (prettyPrint ? NSJSONWritingPrettyPrinted : 0)
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"[]";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end
