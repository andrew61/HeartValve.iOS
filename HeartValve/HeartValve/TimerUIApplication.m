//
//  TimerUIApplication.m
//  MyHealthApp
//
//  Created by Jonathan on 1/23/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "TimerUIApplication.h"

@implementation TimerUIApplication

- (void)sendEvent:(UIEvent *)event
{
    [super sendEvent:event];
    
    if (!idleTimer)
    {
        [self resetIdleTimer];
    }
    
    NSSet *allTouches = [event allTouches];
    if ([allTouches count] > 0)
    {
        UITouchPhase phase = ((UITouch *)[allTouches anyObject]).phase;
        if (phase == UITouchPhaseBegan)
        {
            [self resetIdleTimer];
        }
        
    }
}

- (void)resetIdleTimer
{
    if (idleTimer)
    {
        [idleTimer invalidate];
    }
    
    int timeout = kApplicationTimeoutInMinutes * 60;
    idleTimer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(idleTimerExceeded) userInfo:nil repeats:NO];
    
}

- (void)idleTimerExceeded
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kApplicationDidTimeoutNotification object:nil];
}

@end