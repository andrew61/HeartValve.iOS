//
//  HomeVC.m
//  MyHealthApp
//
//  Created by Jonathan on 1/5/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "HomeVC.h"
#import "Utility.h"
#import "JNKeychain.h"
#import "UserManager.h"
#import "AppVersion.h"
#import "AppDelegate.h"
#import "HealthKitManager.h"
#import "UIColor+Extensions.h"
#import "UIFont+Extensions.h"
#import "AudioPlayer.h"
#import "NotificationManager.h"

@interface HomeVC ()
{
    int soundCount;
}

@property (assign, nonatomic) BOOL updateAvailable;

@end

@implementation HomeVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.updateAvailable = NO;
    self.updateCell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self checkApplicationVersion];
    [self processRemoteNotifications];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.locationManager stopUpdatingLocation];
    [appDelegate transmitLocalStorage];
    [appDelegate processMedicationActivity];
    
    soundCount = 0;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[HealthKitManager sharedManager] requestAuthorization:^{
        [self updateHKImages];
    }];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [UIFont appFontBold:16];
    header.textLabel.textColor = [UIColor appBlueColor];
    header.contentView.backgroundColor = [UIColor whiteColor];
    
    if ([header.textLabel.text isEqualToString:@"VERSION"]) {
        NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
        header.textLabel.text = [NSString stringWithFormat:@"VERSION %@", version];
        //header.textLabel.textAlignment = NSTextAlignmentCenter;
        header.textLabel.textColor = [UIColor blackColor];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *footer = (UITableViewHeaderFooterView *)view;
    footer.textLabel.textColor = [UIColor grayColor];
    footer.textLabel.font = [UIFont appFont:14];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellId = cell.reuseIdentifier;
    
    if ([cellId isEqualToString:@"LogOutCell"])
    {
        [JNKeychain deleteValueForKey:@"auth"];
        [JNKeychain deleteValueForKey:@"pin"];
        
        UIViewController *login = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginVC"];
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.window.rootViewController = login;
        appDelegate.isAppLocked = YES;
    }
    else if ([cellId isEqualToString:@"UpdateCell"])
    {
        if (self.updateAvailable)
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self updateApplication];
        }
    }
    else if ([cellId isEqualToString:@"ActivityCell"])
    {
//        NSInteger randomNumber = arc4random() % 4;
//        
//        switch (soundCount) {
//            case 0:
//                [[AudioPlayer sharedPlayer] playAudioWithFileName:@"cheer1.wav"];
//                break;
//            case 1:
//                [[AudioPlayer sharedPlayer] playAudioWithFileName:@"tiger_rag.wav"];
//                break;
//            case 2:
//                [[AudioPlayer sharedPlayer] playAudioWithFileName:@"clowney.wav"];
//                break;
//            case 3:
//                [[AudioPlayer sharedPlayer] playAudioWithFileName:@"grandpa.mp3"];
//                break;
//                
//            default:
//                break;
//        }
//        
//        soundCount++;
//        
//        if (soundCount >= 4)
//        {
//            soundCount = 0;
//        }
    }
}

- (void)updateHKImages
{
    if ([[HealthKitManager sharedManager] isAuthorizedForBloodPressure])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.bloodPressureHKImage.image = [UIImage imageNamed:@"health-icon.png"];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.bloodPressureHKImage.image = nil;
        });
    }
    
    if ([[HealthKitManager sharedManager] isAuthorizedForWeight])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.weightHKImage.image = [UIImage imageNamed:@"health-icon.png"];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.weightHKImage.image = nil;
        });
    }
    
    if ([[HealthKitManager sharedManager] isAuthorizedForBloodGlucose])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.bloodGlucoseHKImage.image = [UIImage imageNamed:@"health-icon.png"];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.bloodGlucoseHKImage.image = nil;
        });
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self updateHKImages];
}

- (void)checkApplicationVersion
{
    [[UserManager sharedManager] getAppVersion:^(AppVersion *appVersion, NSError *error) {
        if (error == nil) {
            if (![appVersion isCurrentVersion]) {
                NSString *name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
                
                self.versionLabel.text = [NSString stringWithFormat:@"Update to version %@", appVersion.version];
                self.versionLabel.textColor = [UIColor appYellowColor];
                self.updateCell.selectionStyle = UITableViewCellSelectionStyleDefault;
                self.updateAvailable = YES;
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Update Available", nil) message:[NSString stringWithFormat:NSLocalizedString(@"A new version of %@ is available.  Please update to version %@ now.", nil), name, appVersion.version] preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *update = [UIAlertAction actionWithTitle:NSLocalizedString(@"Update", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self updateApplication];
                }];
                
                [alert addAction:update];
                [self.navigationController presentViewController:alert animated:YES completion:nil];
            }
        }
    }];
}


- (void)updateApplication
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kApplicationInstallURL]];
}

- (void)processRemoteNotifications
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (NSDictionary *userInfo in appDelegate.remoteNotifications)
    {
        [[NotificationManager sharedManager] processRemoteNotification:userInfo];
    }
    [appDelegate.remoteNotifications removeAllObjects];
}

@end
