//
//  LoginInformation.m
//  MyHealthApp
//
//  Created by Jonathan on 1/25/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "LoginInformation.h"

@implementation LoginInformation

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"loginInformationId" : @"LoginInformationID",
             @"subject" : @"Subject",
             @"time" : @"Time",
             @"longitude" : @"Longitude",
             @"latitude" : @"Latitude",
             @"model" : @"Model",
             @"os" : @"OS",
             @"network" : @"Network",
             @"phoneType" : @"PhoneType",
             @"appVersion" : @"AppVersion"
             };
}

@end