//
//  SurveyQuestion.h
//  HeartValve
//
//  Created by Tachl on 12/12/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface SurveyQuestion : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSNumber *deleted;
@property (strong, nonatomic) NSString *imagePath;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *questionId;
@property (strong, nonatomic) NSNumber *questionOrder;
@property (strong, nonatomic) NSString *questionText;
@property (strong, nonatomic) NSNumber *questionTypeId;
@property (strong, nonatomic) NSNumber *surveyId;
@property (strong, nonatomic) NSNumber *required;

@end
