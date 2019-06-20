//
//  SurveyQuestionOptions.h
//  HeartValve
//
//  Created by Tachl on 12/12/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>
#import <UIKit/UIKit.h>

@interface SurveyQuestionOptions : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSNumber *optionId;
@property (strong, nonatomic) NSNumber *questionId;
@property (strong, nonatomic) NSNumber *categoryId;
@property (strong, nonatomic) NSString *optionText;
@property (strong, nonatomic) NSNumber *optionValue;
@property (strong, nonatomic) NSNumber *optionOrder;
@property (strong, nonatomic) NSNumber *shapeType;
@property (strong, nonatomic) NSString *coordinates;
@property (strong, nonatomic) NSString *imagePath;
@property (strong, nonatomic) NSNumber *deleted;
@property (strong, nonatomic) NSString *categoryName;
@property (strong, nonatomic) NSString *categoryOrder;
@property (strong, nonatomic) UIImage *image;

@property (assign, nonatomic) BOOL     selected;

@end
