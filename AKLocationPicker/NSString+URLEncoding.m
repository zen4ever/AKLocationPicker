//
//  NSString+URLEncoding.m
//  AKLocationPickerExample
//
//  Created by Andrew Kurinnyi on 11/21/13.
//  Copyright (c) 2013 Andrew Kurinnyi. All rights reserved.
//

#import "NSString+URLEncoding.h"

@implementation NSString (URLEncoding)

-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding {
	return (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes(
           NULL,
           (__bridge CFStringRef)self,
           NULL,
           (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
           CFStringConvertNSStringEncodingToEncoding(encoding));
}


@end
