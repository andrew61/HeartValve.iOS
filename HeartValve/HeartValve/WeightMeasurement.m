//
//  WeightMeasurement.m
//  MyHealthApp
//
//  Created by Jonathan on 12/22/15.
//  Copyright © 2015 MUSC. All rights reserved.
//

#import "WeightMeasurement.h"
#import "DateFormatters.h"

@implementation WeightMeasurement

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{
             @"weightId" : @"WeightId",
             @"weight" : @"Weight",
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

- (instancetype)initWithWeight:(float)weight
{
    self = [super init];
    
    if (self != nil) {
        self.weightId = 0;
        self.weight = @(weight);
        self.readingDate = [NSDate date];
        
    }
    
    return self;
}

@end