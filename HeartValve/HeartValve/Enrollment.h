//
//  Enrollment.h
//  HeartValve
//
//  Created by Tachl on 2/16/17.
//  Copyright © 2017 MUSC. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface Enrollment : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSDate *enrollmentDate;
@property (strong, nonatomic) NSNumber *surveyId;

@end
