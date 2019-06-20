//
//  User.m
//  MyHealthApp
//
//  Created by Jonathan on 1/5/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "User.h"

@implementation User

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"userName" : @"UserName",
             @"firstName" : @"FirstName",
             @"lastName" : @"LastName",
             @"phoneNumber" : @"PhoneNumber"
             };
}

@end
