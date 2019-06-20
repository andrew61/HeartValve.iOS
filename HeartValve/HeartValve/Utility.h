//
//  Utility.h
//  MyHealthApp
//
//  Created by Jonathan on 1/6/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface Utility : NSObject

+ (BOOL)isInternetConnectionAvailable;
+ (MBProgressHUD *)getHUDAddedTo:(UIView *)view withText:(NSString *)text;
+ (UIImage *)imageWithColor:(UIColor *)color;

@end
