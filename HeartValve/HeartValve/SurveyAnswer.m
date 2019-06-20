//
//  SurveyAnswer.m
//  HeartValve
//
//  Created by Tachl on 12/12/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "SurveyAnswer.h"

@implementation SurveyAnswer

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"questionId" : @"QuestionId",
             @"categoryId" : @"CategoryId",
             @"optionId" : @"OptionId",
             @"answerText" : @"AnswerText"
             };
}

@end
