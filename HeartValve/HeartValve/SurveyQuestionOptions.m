//
//  SurveyQuestionOptions.m
//  HeartValve
//
//  Created by Tachl on 12/12/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "SurveyQuestionOptions.h"

@implementation SurveyQuestionOptions

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"categoryId" : @"CategoryId",
             @"categoryName" : @"CategoryName",
             @"coordinates" : @"Coordinates",
             @"deleted" : @"Deleted",
             @"imagePath" : @"ImagePath",
             @"optionId" : @"OptionId",
             @"optionOrder" : @"OptionOrder",
             @"optionText" : @"OptionText",
             @"questionId" : @"QuestionId",
             @"shapeType" : @"ShapeType",
             @"categoryOrder" : @"CategoryOrder",
             };
}

@end
