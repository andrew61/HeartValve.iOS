//
//  NSString+Encode.m
//  MyHealthApp
//
//  Created by Jonathan on 4/11/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "NSString+Encode.h"

@implementation NSString (Encode)

- (NSString *)encodeString:(NSStringEncoding)encoding
{
    return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR(":/?#[]@!$&'()*+,;="), CFStringConvertNSStringEncodingToEncoding(encoding)));
}

@end