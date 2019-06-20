//
//  AppDelegate.h
//  MyHealthApp
//
//  Created by Jonathan on 12/16/15.
//  Copyright © 2015 MUSC. All rights reserved.
//

#define kApplicationPlistURL @"https://hitechnologysolutions.com/Installs/HeartValve/HeartValve.plist"
#define kApplicationInstallURL @"itms-services://?action=download-manifest&url=https://hitechnologysolutions.com/Installs/HeartValve/HeartValve.plist"
#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (assign, nonatomic) BOOL isAppLocked;
@property (assign, nonatomic) BOOL isDataTransmitting;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray *pillCapInstances;
@property (strong, nonatomic) NSMutableArray *remoteNotifications;
@property (assign, nonatomic) BOOL updateAvailable;
@property (assign, nonatomic) NSInteger dailyAssessmentStep;
@property (strong, nonatomic) NSDate *dailyAssessmentDate;

- (void)transmitLocalStorage;
- (void)processMedicationActivity;
- (void)processRemoteNotifications;
- (void)updateApplication;
- (void)updateDailyAssessmentWithStep:(NSInteger)step;
- (void)updateDailyAssessmentForRetake:(NSInteger)step with: (NSDate*) date;
- (void)setDefaultViewController;
- (void)setBehavioralViewController;

@end
