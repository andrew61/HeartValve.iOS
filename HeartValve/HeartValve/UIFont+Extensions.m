//
//  UIFont+Extensions.m
//  MyHealthApp
//
//  Created by Jonathan on 3/2/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "UIFont+Extensions.h"

@implementation UIFont (Extensions)

+ (UIFont *)appFont:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue" size:size];
}

+ (UIFont *)appFontBold:(CGFloat)size
{
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:size];
}

@end