//
//  UIColor+HexValue.m
//  MyHealthApp
//
//  Created by Jonathan on 1/23/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "UIColor+HexValue.h"

@implementation UIColor (HexValue)

+ (UIColor *)colorWithHexValue:(NSString *)hexValue
{
    NSString *cleanedHexValue = [hexValue stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"#"]];
    unsigned long rgbColorValue = strtoul([[cleanedHexValue substringToIndex:6] cStringUsingEncoding:NSASCIIStringEncoding], NULL, 16);
    
    NSUInteger redValue   = (rgbColorValue >> 16) & 0xFF;
    NSUInteger greenValue = (rgbColorValue >>  8) & 0xFF;
    NSUInteger blueValue  = (rgbColorValue >>  0) & 0xFF;
    
    return [UIColor colorWithRed:(redValue / 255.0) green:(greenValue / 255.0) blue:(blueValue / 255.0) alpha:1.0];
}

@end