//
//  TimerUIApplication.h
//  MyHealthApp
//
//  Created by Jonathan on 1/23/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define kApplicationTimeoutInMinutes 10
#define kApplicationDidTimeoutNotification @"AppTimeOut"

@interface TimerUIApplication : UIApplication
{
    NSTimer *idleTimer;
}

- (void)resetIdleTimer;

@end