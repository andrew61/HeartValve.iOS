//
//  Utility.m
//  MyHealthApp
//
//  Created by Jonathan on 1/6/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "Utility.h"
#import <Reachability/Reachability.h>
#import "UIColor+Extensions.h"

@implementation Utility

+ (BOOL)isInternetConnectionAvailable
{
    Reachability *internet = [Reachability reachabilityWithHostName:@"www.google.com"];
    NetworkStatus netStatus = [internet currentReachabilityStatus];
    bool netConnection = false;
    switch (netStatus)
    {
        case NotReachable:
            NSLog(@"Access Not Available");
            netConnection = false;
            break;
            
        case ReachableViaWWAN:
            netConnection = true;
            break;
            
        case ReachableViaWiFi:
            netConnection = true;
            break;
    }
    
    return netConnection;
}

+ (MBProgressHUD *)getHUDAddedTo:(UIView *)view withText:(NSString *)text
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.labelText = text;
    hud.color = [UIColor appYellowColor];
    hud.dimBackground = YES;
    hud.removeFromSuperViewOnHide = YES;
    return hud;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
