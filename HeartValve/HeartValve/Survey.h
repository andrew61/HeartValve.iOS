//
//  Survey.h
//  HeartValve
//
//  Created by Tachl on 12/12/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface Survey : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSNumber *surveyId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSNumber *deleted;
@property (strong, nonatomic) NSNumber *totalQuestions;

@end

