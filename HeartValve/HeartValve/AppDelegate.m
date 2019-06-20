//
//  AppDelegate.m
//  MyHealthApp
//
//  Created by Jonathan on 12/16/15.
//  Copyright © 2015 MUSC. All rights reserved.
//

#import "AppDelegate.h"
#import "JNKeychain.h"
#import "UserManager.h"
#import "APIdleManager.h"
#import "LoginVC.h"
#import "ABPadLockScreenViewController.h"
#import "TimerUIApplication.h"
#import "ABPadLockScreenView.h"
#import "ABPadButton.h"
#import "ABPinSelectionView.h"
#import "UIColor+HexValue.h"
#import "AppVersion.h"
#import "CrashHelper.h"
#import "DbManager.h"
#import "HealthKitManager.h"
#import "Reachability.h"
#import <CoreLocation/CoreLocation.h>
#import "UIColor+Extensions.h"
#import "UIFont+Extensions.h"
#import "NotificationManager.h"
#import "AudioPlayer.h"
#import "Enrollment.h"
#import <AVFoundation/AVFoundation.h>
#import "ActivationStatus.h"


@interface AppDelegate () <ABPadLockScreenViewControllerDelegate, CLLocationManagerDelegate>

@end

@implementation AppDelegate

@synthesize updateAvailable = _updateAvailable;

- (BOOL)updateAvailable
{
    NSDictionary *updateDictionary = [NSDictionary dictionaryWithContentsOfURL:[NSURL URLWithString:kApplicationPlistURL]];
    
    if (updateDictionary)
    {
        NSArray *items = [updateDictionary objectForKey:@"items"];
        NSDictionary *itemDict = [items lastObject];
        NSDictionary *metaData = [itemDict objectForKey:@"metadata"];
        NSString *newversion = [metaData valueForKey:@"bundle-version"];
        NSString *currentversion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        
        return [newversion compare:currentversion options:NSNumericSearch] == NSOrderedDescending;
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.isAppLocked = YES;
    self.isDataTransmitting = NO;
    self.updateAvailable = NO;
    self.remoteNotifications = [NSMutableArray new];
    
    [[CrashHelper sharedHelper] checkForCrashes];
    [[DbManager sharedManager] upgrade];
    
    
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor appYellowColor];
    pageControl.backgroundColor = [UIColor whiteColor];
    [[UITabBar appearance] setTintColor:[UIColor appBlueColor]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidTimeout:) name:kApplicationDidTimeoutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationDidExpire:) name:kAuthenticationDidExpireNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
    
    [self setApplicationAppearance];
    [self setLockScreenAppearance];
    [self setUpReachability];
    [self setUpLocationManager];
    [self setUpNotifications];
    [self setUpFirstLaunch];
    [self setUpDailyAssessment];
    
    [[HealthKitManager sharedManager] requestAuthorization:nil];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    NSDictionary *auth = [JNKeychain loadValueForKey:@"auth"];
    NSString *pin = [JNKeychain loadValueForKey:@"pin"];
    NSDictionary *remoteNotification = [launchOptions valueForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if (remoteNotification)
    {
        [self.remoteNotifications addObject:remoteNotification];
    }
    
    if (auth != nil) {
        if (pin != nil) {
            ABPadLockScreenViewController *lockScreen = [[ABPadLockScreenViewController alloc] initWithDelegate:self complexPin:NO];
            [self setupLockScreen:lockScreen];
            self.window.rootViewController = lockScreen;
            self.isAppLocked = YES;
        }
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CameraVC"];
    //UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SurveyNativeVC"];

    //self.window.rootViewController = vc;

    if ([self dailyAssessmentHasExpired])
    {
        [self setUpDailyAssessment];
        
        [self setDefaultViewController];
    }
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[NotificationManager sharedManager] processLocalNotification:notification];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSDictionary *auth = [JNKeychain loadValueForKey:@"auth"];
    
    if (auth != nil &&
        (self.window.rootViewController.presentedViewController == nil || ![self.window.rootViewController.presentedViewController isKindOfClass:[ABPadLockScreenViewController class]]) &&
        ![self.window.rootViewController isKindOfClass:[ABPadLockScreenViewController class]])
    {
        [[NotificationManager sharedManager] processRemoteNotification:userInfo];
    }
    else
    {
        [self.remoteNotifications addObject:userInfo];
    }
}

- (BOOL)padLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController validatePin:(NSString *)pin
{
    return [pin isEqualToString:[JNKeychain loadValueForKey:@"pin"]];
}

- (void)unlockWasSuccessfulForPadLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController
{
    if ([self.window.rootViewController isKindOfClass:[ABPadLockScreenViewController class]])
    {
        //UIViewController *home = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RevealVC"];
        //self.window.rootViewController = home;
        [self setDefaultViewController];

//        [[UserManager sharedManager]getActivationStatus:^(ActivationStatus *activationStatus, NSError *error) {
//            if([activationStatus.isActive intValue] == 0){
//                [self setActivateViewController];
//            }
//            else{
//                [self setDefaultViewController];
//            }
//        }];
    }
    else
    {
        [padLockScreenViewController dismissViewControllerAnimated:YES completion:nil];
    }
    
    [[UserManager sharedManager] saveLoginInformation:nil];
    [self processRemoteNotifications];
    self.isAppLocked = NO;
}

- (void)unlockWasCancelledForPadLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController
{
    [JNKeychain deleteValueForKey:@"pin"];
    UIViewController *login = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginVC"];
    self.window.rootViewController = login;
}

- (void)unlockWasUnsuccessful:(NSString *)falsePin afterAttemptNumber:(NSInteger)attemptNumber padLockScreenViewController:(ABPadLockScreenViewController *)padLockScreenViewController
{
    if (padLockScreenViewController.remainingAttempts == 0) {
        [JNKeychain deleteValueForKey:@"pin"];
        UIViewController *login = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginVC"];
        self.window.rootViewController = login;
    }
}

- (void)applicationDidTimeout:(NSNotification *)notification
{
    NSString *pin = [JNKeychain loadValueForKey:@"pin"];
    
    if (!self.isAppLocked)
    {
        self.isAppLocked = YES;
        
        if (pin != nil)
        {
            ABPadLockScreenViewController *lockScreen = [[ABPadLockScreenViewController alloc] initWithDelegate:self complexPin:NO];
            [self setupLockScreen:lockScreen];
            
            if (self.window.rootViewController.presentedViewController != nil)
            {
                [self.window.rootViewController.presentedViewController presentViewController:lockScreen animated:YES completion:nil];
            }
            else
            {
                [self.window.rootViewController presentViewController:lockScreen animated:YES completion:nil];
            }
        }
        else
        {
            UIViewController *login = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginVC"];
            self.window.rootViewController = login;
        }
    }
    
    [(TimerUIApplication *)[UIApplication sharedApplication] resetIdleTimer];
}

- (void)authenticationDidExpire:(NSNotification *)notification
{
    [JNKeychain deleteValueForKey:@"auth"];
    [JNKeychain deleteValueForKey:@"pin"];
    
    UIViewController *login = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginVC"];
    self.window.rootViewController = login;
}

- (void)setupLockScreen:(ABPadLockScreenViewController *)lockScreen
{
    [lockScreen setTitle:NSLocalizedString(@"Heart Valve", nil)];
    [lockScreen setLockScreenTitle:NSLocalizedString(@"Heart Valve", nil)];
    [lockScreen setSubtitleText:NSLocalizedString(@"Please enter your passcode", nil)];
    [lockScreen setAllowedAttempts:3];
    [lockScreen.view setBackgroundColor:[UIColor appBlueColor]];
    
    lockScreen.tapSoundEnabled = YES;
    lockScreen.errorVibrateEnabled = YES;
    
    lockScreen.modalPresentationStyle = UIModalPresentationFullScreen;
    lockScreen.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
}

- (void)setApplicationAppearance
{
    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTintColor:[UIColor appBlueColor]];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setShadowImage:[UIImage new]];
    //[[UINavigationBar appearance] setBackgroundImage:[UIImage new] forBarPosition:UIBarPositionAny barMetrics:UIBarMetricsDefault];
    //[[UINavigationBar appearance] setBackIndicatorImage:[UIImage imageNamed:@"back.png"]];
    //[[UINavigationBar appearance] setBackIndicatorTransitionMaskImage:[UIImage imageNamed:@"back.png"]];
    [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor appBlueColor], NSForegroundColorAttributeName,
                                                          [UIFont appFontBold:18], NSFontAttributeName,
                                                          nil]];
    [[UITableView appearance] setBackgroundColor:[UIColor whiteColor]];
    //[[UILabel appearance] setFont:[UIFont appFont:16]];
    
    //UIView *selectedBackgroundView = [[UIView alloc] init];
    //[selectedBackgroundView setBackgroundColor:[UIColor whiteColor]];
    //[[UITableViewCell appearance] setSelectedBackgroundView:selectedBackgroundView];
    
    [[UITabBar appearance] setBackgroundColor:[UIColor appBlueColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor appBlueColor]];
    [[UITabBar appearance] setTranslucent:NO];
    [[UITabBar appearance] setTintColor:[UIColor whiteColor]];
    [[UITabBarItem appearance] setTitleTextAttributes:@{
                                                        NSForegroundColorAttributeName : [UIColor lightGrayColor],
                                                        NSFontAttributeName : [UIFont appFontBold:12]
                                                        }
                                             forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{
                                                        NSForegroundColorAttributeName : [UIColor whiteColor],
                                                        NSFontAttributeName : [UIFont appFontBold:12]
                                                        }
                                             forState:UIControlStateSelected];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                        NSForegroundColorAttributeName : [UIColor appYellowColor],
                                                        NSFontAttributeName : [UIFont appFont:18]
                                                        }
                                             forState:UIControlStateHighlighted];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                           NSForegroundColorAttributeName : [UIColor appYellowColor],
                                                           NSFontAttributeName : [UIFont appFont:18]
                                                           }
                                                forState:UIControlStateNormal];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
                                                           NSFontAttributeName : [UIFont appFont:18]
                                                           }
                                                forState:UIControlStateDisabled];
}

- (void)setLockScreenAppearance
{
//    [[ABPadLockScreenView appearance] sizeThatFits:CGSizeMake(self., 200)];
    [[ABPadLockScreenView appearance] setBackgroundColor:[UIColor appBlueColor]];
    [[ABPadLockScreenView appearance] setLabelColor:[UIColor whiteColor]];
    [[ABPadButton appearance] setBackgroundColor:[UIColor appBlueColor]];
    [[ABPadButton appearance] setBorderColor:[UIColor appBlueColor]];
    [[ABPadButton appearance] setSelectedColor:[UIColor appBlueColor]];
    [[ABPinSelectionView appearance] setSelectedColor:[UIColor appYellowColor]];
}

- (void)setUpReachability
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    [reachability startNotifier];
}

- (void)reachabilityChanged:(NSNotification *)notification
{
    Reachability *reachability = [notification object];
    NetworkStatus status = [reachability currentReachabilityStatus];
    
    if (status != NotReachable)
    {
        [self transmitLocalStorage];
    }
}

- (void)setUpLocationManager
{
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (void)setUpNotifications
{
    [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound) categories:nil]];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSString *token = [[[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:token forKey:@"deviceToken"];
}

- (void)setUpFirstLaunch
{
    NSDate *firstLaunchDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"firstLaunchDate"];
    
    if (firstLaunchDate == nil)
    {
        [JNKeychain deleteValueForKey:@"auth"];
        [JNKeychain deleteValueForKey:@"pin"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"firstLaunchDate"];
    }
    
}

- (void)setUpDailyAssessment
{
    NSDictionary *dailyAssessment = [[NSUserDefaults standardUserDefaults] objectForKey:@"dailyAssessment"];
    
    if (dailyAssessment != nil)
    {
        self.dailyAssessmentStep = [dailyAssessment[@"step"] intValue];
        //self.dailyAssessmentStep = 5;//comment this later
        self.dailyAssessmentDate = dailyAssessment[@"date"];
        
        if ([self dailyAssessmentHasExpired])
        {
            self.dailyAssessmentStep = 1;
            self.dailyAssessmentDate = [NSDate date];
        }
    }
    else
    {
        self.dailyAssessmentStep = 1;
        self.dailyAssessmentDate = [NSDate date];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:@{@"step":@(self.dailyAssessmentStep),@"date":self.dailyAssessmentDate} forKey:@"dailyAssessment"];
}

- (void)updateApplication
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kApplicationInstallURL]];
    
    ///Closes the App for install.
    exit(0);
}

- (void)transmitLocalStorage
{
    if (!self.isDataTransmitting)
    {
        self.isDataTransmitting = YES;
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSMutableArray *bloodPressureMeasurements = [[DbManager sharedManager] getBloodPressureMeasurements];
            NSMutableArray *bloodGlucoseMeasurements = [[DbManager sharedManager] getBloodGlucoseMeasurements];
            NSMutableArray *weightMeasurements = [[DbManager sharedManager] getWeightMeasurements];
            NSMutableArray *oxygenSaturation = [[DbManager sharedManager] getOxygenSaturation];
            
            for (BloodPressureMeasurement *measurement in bloodPressureMeasurements)
            {
                //save to health kit
//                [[HealthKitManager sharedManager] saveBloodPressure:measurement];
                
                [[UserManager sharedManager] saveBloodPressureMeasurement:measurement completion:^(NSError *error) {
                    if (error == nil)
                    {
                        [[DbManager sharedManager] deleteBloodPressureMeasurement:measurement];
                    }
                }];
            }
            
            for (BloodGlucoseMeasurement *measurement in bloodGlucoseMeasurements)
            {
                //save to health kit
//                [[HealthKitManager sharedManager] saveBloodGlucose:measurement];
                
                [[UserManager sharedManager] saveBloodGlucoseMeasurement:measurement completion:^(NSError *error) {
                    if (error == nil)
                    {
                        [[DbManager sharedManager] deleteBloodGlucoseMeasurement:measurement];
                    }
                }];
            }
            
            for (WeightMeasurement *measurement in weightMeasurements)
            {
                //save to health kit
//                [[HealthKitManager sharedManager] saveWeight:measurement];
                
                [[UserManager sharedManager] saveWeightMeasurement:measurement completion:^(NSError *error) {
                    if (error == nil)
                    {
                        [[DbManager sharedManager] deleteWeightMeasurement:measurement];
                    }
                }];
            }
            
            for (OxygenSaturation *measurement in oxygenSaturation)
            {
                //save to health kit
//              [[HealthKitManager sharedManager] saveOxygenSaturation:measurement];
                
                [[UserManager sharedManager] saveOxygenSaturation:measurement completion:^(NSError *error) {
                    if (error == nil)
                    {
                        [[DbManager sharedManager] deleteOxygenSaturation:measurement];
                    }
                }];
            }
            
            self.isDataTransmitting = NO;
        });
    }
}


- (void)processRemoteNotifications
{
    for (NSDictionary *userInfo in self.remoteNotifications)
    {
        [[NotificationManager sharedManager] processRemoteNotification:userInfo];
    }
    [self.remoteNotifications removeAllObjects];
}




- (void)updateDailyAssessmentWithStep:(NSInteger)step
{
    self.dailyAssessmentStep = step;
    NSDictionary *dailyAssessment = [[NSUserDefaults standardUserDefaults] objectForKey:@"dailyAssessment"];
    [[NSUserDefaults standardUserDefaults] setObject:@{@"step":@(step),@"date":dailyAssessment[@"date"]} forKey:@"dailyAssessment"];
}

- (void)updateDailyAssessmentForRetake:(NSInteger)step with: (NSDate*) date
{
    self.dailyAssessmentStep = step;
    [[NSUserDefaults standardUserDefaults] setObject:@{@"step":@(step),@"date":date} forKey:@"dailyAssessment"];
}

- (void)setDefaultViewController
{
    switch (self.dailyAssessmentStep)
    {

        case 1:
        {
            UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WelcomeVC"];
            self.window.rootViewController = vc;
            break;
        }
            
        case 2:
        {
//            UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ContinueSurveyVC"];
            
            UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]  instantiateViewControllerWithIdentifier:@"ContinueSurveyVCNav"];
//            UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ContinueSurveyVC"];
            self.window.rootViewController = nav;
            

//            [nav pushViewController:vc animated:YES];
//            [self presentViewController:nav animated:YES completion:nil];
            break;
        }
            
        case 3:
        {
            UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"WeightGuidedVC"];
            self.window.rootViewController = vc;
            break;
        }
            
        case 4:
        {
            UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"BloodPressureGuidedVC"];
            self.window.rootViewController = vc;
            break;
        }
            
//        case 5:
//        {
//            UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"OxygenSaturationGuidedVC"];
//            self.window.rootViewController = vc;
//            break;
//        }
            
        case 5:
        {
            UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"CompletionVC"];
            self.window.rootViewController = vc;
            break;
        }
            
        default:
        {
            UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RevealVC"];
            self.window.rootViewController = vc;
            break;
        }
    }
}
- (void)setActivateViewController
{
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginVC"];
    self.window.rootViewController = vc;
}

- (void)setBehavioralViewController{
//    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"BehavioralSurveyVC"];
    
    UINavigationController *nav = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]  instantiateViewControllerWithIdentifier:@"ContinueBehavioralSurveyVC"];
    //            UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ContinueSurveyVC"];
    self.window.rootViewController = nav;
}

- (BOOL)dailyAssessmentHasExpired
{
    NSDate *date = [NSDate date];
    NSDateComponents *components1 = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:self.dailyAssessmentDate];
    NSDateComponents *components2 = [[NSCalendar currentCalendar] components:(NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear) fromDate:date];
    
    if ([components2 year] > [components1 year] ||
        ([components2 year] == [components1 year] && [components2 month] > [components1 month]) ||
        ([components2 year] == [components1 year] && [components2 month] == [components1 month] && [components2 day] > [components1 day]))
    {
        return YES;
    }
    
    return NO;
}

@end
