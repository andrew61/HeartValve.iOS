//
//  BloodPressureMeasurement.h
//  MyHealthApp
//
//  Created by Jonathan on 12/17/15.
//  Copyright © 2015 MUSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface BloodPressureMeasurement : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSNumber *bloodPressureId;
@property (strong, nonatomic) NSNumber *systolic;
@property (strong, nonatomic) NSNumber *diastolic;
@property (strong, nonatomic) NSNumber *map;
@property (strong, nonatomic) NSNumber *pulse;
@property (strong, nonatomic) NSDate *readingDate;

- (instancetype)initWithSystolic:(int)systolic diastolic:(int)diastolic map:(int)map pulse:(int)pulse;

@end