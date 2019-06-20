//
//  OxygenSaturation.m
//  HeartValve
//
//  Created by Jonathan on 10/11/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "OxygenSaturation.h"
#import "DateFormatters.h"

@implementation OxygenSaturation

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"oxygenSaturationId" : @"OxygenSaturationId",
             @"spO2" : @"SpO2",
             @"heartRate" : @"HeartRate",
             @"readingDate" : @"ReadingDate"
             };
}

+ (NSValueTransformer *)readingDateJSONTransformer
{
    return [MTLValueTransformer reversibleTransformerWithForwardBlock:^(NSString *str){
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

@end
