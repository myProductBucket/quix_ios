//
//  NSArray+RJSON.h
//  Quix
//
//  Created by Matti Heikkinen on 12/24/15.
//  Copyright © 2015 self. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (RJSON)

- (NSString *)rj_jsonStringWithPrettyPrint:(BOOL)prettyPrint;

@end
