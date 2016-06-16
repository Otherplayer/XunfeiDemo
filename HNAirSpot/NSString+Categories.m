//
//  NSString+Categories.m
//  HNAirSpot
//
//  Created by __无邪_ on 16/6/16.
//  Copyright © 2016年 __无邪_. All rights reserved.
//

#import "NSString+Categories.h"

@implementation NSString (Categories)
- (NSDictionary *)jsonInfo{
    NSError *error = nil;
    NSData *data;
    if([self dataUsingEncoding:NSASCIIStringEncoding])
    {
        data = [self dataUsingEncoding:NSASCIIStringEncoding];
    }else{
        data = [self dataUsingEncoding:NSUTF8StringEncoding];
    }
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:data
                                                               options:NSJSONReadingAllowFragments
                                                                 error:&error];
    
    if (jsonObject != nil && error == nil){
        return jsonObject;
    }
    return nil;
}

- (BOOL)isExist{
    if (self == NULL) {
        return NO;
    }else if (!self){
        return NO;
    }else if ([self trimmingWhitespaceAndNewlines].length == 0){
        return NO;
    }
    return YES;
}

- (NSString *)trimmingWhitespace{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}
- (NSString *)trimmingWhitespaceAndNewlines{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
