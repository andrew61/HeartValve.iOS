//
//  ActivationStatus.m
//  HeartValve
//
//  Created by Jameson B on 1/10/18.
//  Copyright © 2018 MUSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ActivationStatus.h"
#import "DateFormatters.h"

@implementation ActivationStatus

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"enrollmentDate" : @"EnrollmentDate",
             @"isActive" : @"isActive",
             };
}

+ (NSValueTransformer *)readingDateJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str){
        //str = [str substringFromIndex:10];
        NSDate *date = [[DateFormatters receiveJSONDateFormatter] dateFromString:str];
        return date;
    }reverseBlock:^(NSDate *date){
        return [[DateFormatters sendJSONDateFormatter] stringFromDate:date];
    }];
}

@end
