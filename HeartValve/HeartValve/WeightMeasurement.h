//
//  WeightMeasurement.h
//  MyHealthApp
//
//  Created by Jonathan on 12/22/15.
//  Copyright © 2015 MUSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface WeightMeasurement : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSNumber *weightId;
@property (strong, nonatomic) NSNumber *weight;
@property (strong, nonatomic) NSDate *readingDate;

- (instancetype)initWithWeight:(float)weight;

@end
