//
//  HealthKitManager.h
//  MyHealthApp
//
//  Created by Jonathan on 2/22/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WeightMeasurement;
@class BloodPressureMeasurement;
@class BloodGlucoseMeasurement;
@class OxygenSaturation;

@interface HealthKitManager : NSObject

+ (HealthKitManager *)sharedManager;

- (void)requestAuthorization:(void (^)(void))completion;
- (BOOL)isAuthorizedForBloodPressure;
- (BOOL)isAuthorizedForBloodGlucose;
- (BOOL)isAuthorizedForWeight;
- (BOOL)isAuthorizedForOxygenSaturation;
- (void)saveWeight:(WeightMeasurement *)measurement;
- (void)saveBloodPressure:(BloodPressureMeasurement *)measurement;
- (void)saveBloodGlucose:(BloodGlucoseMeasurement *)measurement;
- (void)saveOxygenSaturation:(OxygenSaturation *)measurement;

@end
