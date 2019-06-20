//
//  OxygenSaturation.h
//  HeartValve
//
//  Created by Jonathan on 10/11/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface OxygenSaturation : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSNumber *oxygenSaturationId;
@property (strong, nonatomic) NSNumber *spO2;
@property (strong, nonatomic) NSNumber *heartRate;
@property (strong, nonatomic) NSDate *readingDate;

@end
