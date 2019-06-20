//
//  Enrollment.m
//  HeartValve
//
//  Created by Tachl on 2/16/17.
//  Copyright © 2017 MUSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Enrollment.h"
#import "DateFormatters.h"

@implementation Enrollment

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"enrollmentDate" : @"EnrollmentDate",
             @"surveyId" : @"SurveyId",
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
