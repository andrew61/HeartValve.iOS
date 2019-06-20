//
//  HealthKitManager.m
//  MyHealthApp
//
//  Created by Jonathan on 2/22/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "HealthKitManager.h"
#import "WeightMeasurement.h"
#import "BloodPressureMeasurement.h"
#import "BloodGlucoseMeasurement.h"
#import "OxygenSaturation.h"

@import HealthKit;

@interface HealthKitManager ()

@property (retain, nonatomic) HKHealthStore *healthStore;

@end

@implementation HealthKitManager

+ (HealthKitManager *)sharedManager
{
    static HealthKitManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        sharedManager.healthStore = [[HKHealthStore alloc] init];
    });
    return sharedManager;
}

- (void)requestAuthorization:(void (^)(void))completion
{
    if ([HKHealthStore isHealthDataAvailable])
    {
        NSSet *writeDataTypes = [self dataTypesToWrite];
        //NSSet *readDataTypes = [self dataTypesToRead];
        
        [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:nil completion:^(BOOL success, NSError * _Nullable error) {
            if (completion) {
                completion();
            }
        }];
    }
}

- (NSSet *)dataTypesToWrite
{
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantityType *bloodGlucoseType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];
    HKQuantityType *bloodPressureSystolicType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    HKQuantityType *bloodPressureDiastolicType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];
    HKQuantityType *heartRateType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKQuantityType *oxygenSaturationType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierOxygenSaturation];
    
    return [NSSet setWithObjects:heightType, weightType, bloodGlucoseType, bloodPressureSystolicType, bloodPressureDiastolicType, heartRateType, oxygenSaturationType, nil];
}

- (NSSet *)dataTypesToRead
{
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKQuantityType *bloodGlucoseType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];
    HKQuantityType *bloodPressureSystolicType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
    HKQuantityType *bloodPressureDiastolicType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];
    HKQuantityType *heartRateType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
    HKQuantityType *oxygenSaturationType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierOxygenSaturation];
    
    return [NSSet setWithObjects:heightType, weightType, bloodGlucoseType, bloodPressureSystolicType, bloodPressureDiastolicType, heartRateType, oxygenSaturationType, nil];
}

- (BOOL)isAuthorizedForBloodPressure
{
    HKAuthorizationStatus systolicStatus = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic]];
    HKAuthorizationStatus diastolicStatus = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic]];
    HKAuthorizationStatus heartRateStatus = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate]];
    
    if (systolicStatus == HKAuthorizationStatusSharingAuthorized &&
        diastolicStatus == HKAuthorizationStatusSharingAuthorized &&
        heartRateStatus == HKAuthorizationStatusSharingAuthorized) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isAuthorizedForBloodGlucose
{
    HKAuthorizationStatus status = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose]];
    
    if (status == HKAuthorizationStatusSharingAuthorized) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isAuthorizedForWeight
{
    HKAuthorizationStatus status = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass]];
    
    if (status == HKAuthorizationStatusSharingAuthorized) {
        return YES;
    }
    
    return NO;
}

- (BOOL)isAuthorizedForOxygenSaturation
{
    HKAuthorizationStatus status = [self.healthStore authorizationStatusForType:[HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierOxygenSaturation]];
    
    if (status == HKAuthorizationStatusSharingAuthorized) {
        return YES;
    }
    
    return NO;
}

- (void)saveWeight:(WeightMeasurement *)measurement
{
    if ([self isAuthorizedForWeight])
    {
        HKUnit *poundUnit = [HKUnit poundUnit];
        HKQuantity *weightQuantity = [HKQuantity quantityWithUnit:poundUnit doubleValue:measurement.weight.doubleValue];
        HKQuantityType *weightType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
        HKQuantitySample *weightSample = [HKQuantitySample quantitySampleWithType:weightType quantity:weightQuantity startDate:measurement.readingDate endDate:measurement.readingDate];
        
        [self.healthStore saveObject:weightSample withCompletion:^(BOOL success, NSError *error) {
            
        }];
    }
}

- (void)saveBloodPressure:(BloodPressureMeasurement *)measurement
{
    if ([self isAuthorizedForBloodPressure])
    {
        HKUnit *bloodPressureUnit = [HKUnit millimeterOfMercuryUnit];
        HKUnit *heartRateUnit = [HKUnit unitFromString:@"count/min"];
        
        HKQuantity *systolicQuantity = [HKQuantity quantityWithUnit:bloodPressureUnit doubleValue:measurement.systolic.doubleValue];
        HKQuantity *diastolicQuantity = [HKQuantity quantityWithUnit:bloodPressureUnit doubleValue:measurement.diastolic.doubleValue];
        HKQuantity *heartRateQuantity = [HKQuantity quantityWithUnit:heartRateUnit doubleValue:measurement.pulse.doubleValue];
        
        HKQuantityType *systolicType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureSystolic];
        HKQuantityType *diastolicType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodPressureDiastolic];
        HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];
        
        HKQuantitySample *systolicSample = [HKQuantitySample quantitySampleWithType:systolicType quantity:systolicQuantity startDate:measurement.readingDate endDate:measurement.readingDate];
        HKQuantitySample *diastolicSample = [HKQuantitySample quantitySampleWithType:diastolicType quantity:diastolicQuantity startDate:measurement.readingDate endDate:measurement.readingDate];
        HKQuantitySample *heartRateSample = [HKQuantitySample quantitySampleWithType:heartRateType quantity:heartRateQuantity startDate:measurement.readingDate endDate:measurement.readingDate];
        
        NSSet *objects = [NSSet setWithObjects:systolicSample, diastolicSample, nil];
        HKCorrelationType *bloodPressureType = [HKObjectType correlationTypeForIdentifier:HKCorrelationTypeIdentifierBloodPressure];
        HKCorrelation *bloodPressure = [HKCorrelation correlationWithType:bloodPressureType startDate:measurement.readingDate endDate:measurement.readingDate objects:objects];
        
        [self.healthStore saveObject:bloodPressure withCompletion:^(BOOL success, NSError * _Nullable error) {
            
        }];
        
        [self.healthStore saveObject:heartRateSample withCompletion:^(BOOL success, NSError * _Nullable error) {
            
        }];
    }
}

- (void)saveBloodGlucose:(BloodGlucoseMeasurement *)measurement
{
    if ([self isAuthorizedForBloodGlucose])
    {
        HKUnit *bloodGlucoseUnit = [HKUnit unitFromString:@"mg/dl"];
        HKQuantity *bloodGlucoseQuantity = [HKQuantity quantityWithUnit:bloodGlucoseUnit doubleValue:measurement.glucoseLevel.doubleValue];
        HKQuantityType *bloodGlucoseType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierBloodGlucose];
        HKQuantitySample *bloodGlucoseSample = [HKQuantitySample quantitySampleWithType:bloodGlucoseType quantity:bloodGlucoseQuantity startDate:measurement.readingDate endDate:measurement.readingDate];
        
        [self.healthStore saveObject:bloodGlucoseSample withCompletion:^(BOOL success, NSError * _Nullable error) {
            
        }];
    }
}

- (void)saveOxygenSaturation:(OxygenSaturation *)measurement
{
    if ([self isAuthorizedForOxygenSaturation])
    {
        HKUnit *spO2Unit = [HKUnit percentUnit];
        
        HKQuantity *spO2Quantity = [HKQuantity quantityWithUnit:spO2Unit doubleValue:measurement.spO2.doubleValue / 100];
        
        HKQuantityType *spO2Type = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierOxygenSaturation];
        
        HKQuantitySample *spO2Sample = [HKQuantitySample quantitySampleWithType:spO2Type quantity:spO2Quantity startDate:measurement.readingDate endDate:measurement.readingDate];
        [self.healthStore saveObject:spO2Sample withCompletion:^(BOOL success, NSError * _Nullable error) {
            
        }];
        /**
        //No longer being send to healthKit.

//        HKUnit *heartRateUnit = [HKUnit unitFromString:@"count/min"];
//
//        HKQuantity *heartRateQuantity = [HKQuantity quantityWithUnit:heartRateUnit doubleValue:measurement.heartRate.doubleValue];
        
//        HKQuantityType *heartRateType = [HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeartRate];

        //        HKQuantitySample *heartRateSample = [HKQuantitySample quantitySampleWithType:heartRateType quantity:heartRateQuantity startDate:measurement.readingDate endDate:measurement.readingDate];
        
//        [self.healthStore saveObject:heartRateSample withCompletion:^(BOOL success, NSError * _Nullable error) {
//            
//        }];
         **/
    }
}

@end
