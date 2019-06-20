//
//  SurveyQuestion.m
//  HeartValve
//
//  Created by Tachl on 12/12/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "SurveyQuestion.h"

@implementation SurveyQuestion

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"deleted" : @"Deleted",
             @"imagePath" : @"ImagePath",
             @"name" : @"Name",
             @"questionId" : @"QuestionId",
             @"questionOrder" : @"QuestionOrder",
             @"questionText" : @"QuestionText",
             @"questionTypeId" : @"QuestionTypeId",
             @"surveyId" : @"SurveyId",
             @"required" : @"Required"
             };
}

@end
