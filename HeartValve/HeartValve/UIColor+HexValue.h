//
//  UIColor+HexValue.h
//  MyHealthApp
//
//  Created by Jonathan on 1/23/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (HexValue)

+ (UIColor *)colorWithHexValue:(NSString *)hexValue;

@end