//
//  UIColor+Extensions.m
//  MyHealthApp
//
//  Created by Jonathan on 2/25/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "UIColor+Extensions.h"
#import "UIColor+HexValue.h"

@implementation UIColor (Extensions)

+ (UIColor *)appBlueColor
{
    return [UIColor colorWithHexValue:@"2E5673"];
}

+ (UIColor *)appYellowColor
{
    return [UIColor colorWithHexValue:@"E7A218"];
}

+ (UIColor *)appleBlueColor
{
    return [UIColor colorWithHexValue:@"007AFF"];
}


@end
