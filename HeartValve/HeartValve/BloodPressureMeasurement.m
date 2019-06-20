//
//  BloodPressureMeasurement.m
//  MyHealthApp
//
//  Created by Jonathan on 12/17/15.
//  Copyright © 2015 MUSC. All rights reserved.
//

#import "BloodPressureMeasurement.h"
#import "DateFormatters.h"

@implementation BloodPressureMeasurement

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"bloodPressureId" : @"BloodPressureId",
             @"systolic" : @"Systolic",
             @"diastolic" : @"Diastolic",
             @"map" : @"Map",
             @"pulse" : @"Pulse",
             @"readingDate" : @"ReadingDate"
             };
}

+ (NSValueTransformer *)readingDateJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str){
        //str = [str substringFromIndex:10];
        NSDate *date = [[DateFormatters receiveJSONDateFormatter] dateFromString:str];
        return date;
    } reverseBlock:^(NSDate *date){
        return [[DateFormatters sendJSONDateFormatter] stringFromDate:date];
    }];
}

- (instancetype)init
{
    self = [super init];
    
    if (self != nil) {
        self.readingDate = [NSDate date];
    }
    
    return self;
}

- (instancetype)initWithSystolic:(int)systolic diastolic:(int)diastolic map:(int)map pulse:(int)pulse
{
    self = [super init];
    
    if (self != nil) {
        self.bloodPressureId = 0;
        self.systolic = @(systolic);
        self.diastolic = @(diastolic);
        self.map = @(map);
        self.pulse = @(pulse);
        self.readingDate = [NSDate date];
    }
    
    return self;
}

@end