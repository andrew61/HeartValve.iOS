//
//  BloodGlucoseMeasurement.m
//  MyHealthApp
//
//  Created by Jonathan on 1/15/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "BloodGlucoseMeasurement.h"
#import "DateFormatters.h"

@implementation BloodGlucoseMeasurement

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"bloodGlucoseId" : @"BloodGlucoseId",
             @"glucoseLevel" : @"GlucoseLevel",
             @"readingDate" : @"ReadingDate"
             };
}

+ (NSValueTransformer *)readingDateJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str){
        //str = [str substringFromIndex:10];
        NSDate *date = [[DateFormatters receiveJSONDateFormatter] dateFromString:str];
        return date;
    }reverseBlock:^(NSDate *date){
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

- (instancetype)initWithGlucoseLevel:(int)glucoseLevel
{
    self = [super init];
    
    if (self != nil) {
        self.bloodGlucoseId = 0;
        self.glucoseLevel = @(glucoseLevel);
        self.readingDate = [NSDate date];
    }
    
    return self;
}

@end