//
//  CrashHelper.h
//  MyHealthApp
//
//  Created by Jonathan on 2/12/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CrashHelper : NSObject

+ (CrashHelper *)sharedHelper;
- (void)checkForCrashes;

@end