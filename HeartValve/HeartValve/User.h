//
//  User.h
//  MyHealthApp
//
//  Created by Jonathan on 1/5/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface User : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *firstName;
@property (strong, nonatomic) NSString *lastName;
@property (strong, nonatomic) NSString *phoneNumber;

@end
