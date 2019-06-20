//
//  Survey.m
//  HeartValve
//
//  Created by Tachl on 12/12/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "Survey.h"

@implementation Survey

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"surveyId" : @"SurveyId",
             @"name" : @"Name",
             @"deleted" : @"Deleted",
             @"totalQuestions" : @"TotalQuestions"
             };
}

@end
