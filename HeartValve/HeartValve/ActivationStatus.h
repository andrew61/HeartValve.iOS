//
//  ActivationStatus.h
//  HeartValve
//
//  Created by Jameson B on 1/10/18.
//  Copyright © 2018 MUSC. All rights reserved.
//

#import <Mantle/Mantle.h>

@interface ActivationStatus : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSDate *enrollmentDate;
@property (strong, nonatomic) NSNumber *isActive;

@end
