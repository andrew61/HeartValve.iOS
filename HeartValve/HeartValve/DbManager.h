//
//  DbManager.h
//  MyHealthApp
//
//  Created by Jonathan on 1/30/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DATABASE_FILENAME @"HeartValve.sql"

@class BloodPressureMeasurement;
@class BloodGlucoseMeasurement;
@class WeightMeasurement;
@class OxygenSaturation;

@interface DbManager : NSObject

+ (DbManager *)sharedManager;

- (void)upgrade;
- (BOOL)insertBloodPressureMeasurement:(BloodPressureMeasurement *)measurement;
- (BOOL)insertBloodGlucoseMeasurement:(BloodGlucoseMeasurement *)measurement;
- (BOOL)insertWeightMeasurement:(WeightMeasurement *)measurement;
- (BOOL)insertOxygenSaturation:(OxygenSaturation *)measurement;
- (BOOL)deleteBloodPressureMeasurement:(BloodPressureMeasurement *)measurement;
- (BOOL)deleteBloodGlucoseMeasurement:(BloodGlucoseMeasurement *)measurement;
- (BOOL)deleteWeightMeasurement:(WeightMeasurement *)measurement;
- (BOOL)deleteOxygenSaturation:(OxygenSaturation *)measurement;
- (NSMutableArray *)getBloodPressureMeasurements;
- (NSMutableArray *)getBloodGlucoseMeasurements;
- (NSMutableArray *)getWeightMeasurements;
- (NSMutableArray *)getOxygenSaturation;

@end
