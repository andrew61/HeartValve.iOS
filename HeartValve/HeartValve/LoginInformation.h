//
//  LoginInformation.h
//  MyHealthApp
//
//  Created by Jonathan on 1/25/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface LoginInformation : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSNumber *loginInformationId;
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSNumber *longitude;
@property (strong, nonatomic) NSNumber *latitude;
@property (strong, nonatomic) NSString *model;
@property (strong, nonatomic) NSString *os;
@property (strong, nonatomic) NSString *network;
@property (strong, nonatomic) NSString *phoneType;
@property (strong, nonatomic) NSString *appVersion;

@end