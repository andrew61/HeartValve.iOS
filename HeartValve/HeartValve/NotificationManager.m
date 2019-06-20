//
//  NotificationManager.m
//  MyHealthApp
//
//  Created by Jonathan on 3/15/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "NotificationManager.h"
#import "DateFormatters.h"
#import "UserManager.h"
#import <TelerikUI/TelerikUI.h>

@implementation NotificationManager

+ (NotificationManager *)sharedManager
{
    static NotificationManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

+ (void)scheduleLocalNotificationsWithScheduleGroup:(MedicationScheduleGroup *)group
{
    [self cancelLocalNotificationsWithScheduleGroup:group];
       
}

+ (void)cancelLocalNotificationsWithScheduleGroup:(MedicationScheduleGroup *)group
{
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notification in notifications)
    {
        
    }
}

- (void)processLocalNotification:(UILocalNotification *)notification
{
    
}

- (void)processRemoteNotification:(NSDictionary *)userInfo
{
    
}

@end
