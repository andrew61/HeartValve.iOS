//
//  SurveyAnswer.h
//  HeartValve
//
//  Created by Tachl on 12/12/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface SurveyAnswer : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSNumber *questionId;
@property (strong, nonatomic) NSNumber *categoryId;
@property (strong, nonatomic) NSNumber *optionId;
@property (strong, nonatomic) NSString *answerText;

@end
