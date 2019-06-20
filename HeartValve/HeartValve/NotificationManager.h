//
//  NotificationManager.h
//  MyHealthApp
//
//  Created by Jonathan on 3/15/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#define kMedicationWasTakenNotification @"MedicationWasTaken"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MedicationScheduleGroup;

@interface NotificationManager : NSObject

+ (NotificationManager *)sharedManager;
+ (void)scheduleLocalNotificationsWithScheduleGroup:(MedicationScheduleGroup *)group;
+ (void)cancelLocalNotificationsWithScheduleGroup:(MedicationScheduleGroup *)group;
- (void)processLocalNotification:(UILocalNotification *)notification;
- (void)processRemoteNotification:(NSDictionary *)userInfo;

@end
