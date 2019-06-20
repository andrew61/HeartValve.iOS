//
//  AppVersion.h
//  MyHealthApp
//
//  Created by Jonathan on 1/26/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Mantle/Mantle.h>

@interface AppVersion : MTLModel <MTLJSONSerializing>

@property (strong, nonatomic) NSString *version;

- (BOOL)isCurrentVersion;

@end