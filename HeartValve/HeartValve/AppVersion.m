//
//  AppVersion.m
//  MyHealthApp
//
//  Created by Jonathan on 1/26/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "AppVersion.h"

@implementation AppVersion

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"version" : @"iOSVersion"
             };
}

- (BOOL)isCurrentVersion
{
    NSString *currentVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    if ([self.version isEqualToString:currentVersion]) {
        return YES;
    }
    
    return NO;
}

@end