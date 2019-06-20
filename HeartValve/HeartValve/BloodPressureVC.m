//
//  BloodPressureVC.m
//  MyHealthApp
//
//  Created by Jonathan on 1/5/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "BloodPressureVC.h"
#import "BloodPressureMeasurement.h"
#import "AD_UA_651BLE.h"
#import "UserManager.h"
#import "MBProgressHUD.h"
#import "UIColor+HexValue.h"
#import "DbManager.h"
#import "HealthKitManager.h"
#import "UIColor+Extensions.h"
#import "UIFont+Extensions.h"
#import "Utility.h"
#import "AudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import <LocalAuthentication/LocalAuthentication.h>
#import "JNKeychain.h"

@interface BloodPressureVC ()

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *timerStartDate;

@end

@implementation BloodPressureVC
{
    BloodPressureMeasurement *currentBloodPressure;
    AVSpeechSynthesizer *synthesizer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];

    self.bpDevice = [[AD_UA_651BLE alloc] initWithDelegate:self];
    self.bpAttempt = 1;
    synthesizer = [AVSpeechSynthesizer new];
    self.bpInProgress = YES;
    self.systolicView.hidden = YES;
    self.diastolicView.hidden = YES;
    self.pulseView.hidden = YES;
    self.instructionsLabel.text = NSLocalizedString(@"Push the START button on the blood pressure machine.  Please hold still, do not move or talk", nil);
    [AudioPlayer speak:@"Please sit down and relax. Place the blood pressure cuff securely on your bear upper arm. The bottom of the cuff should be a half inch above your elbow. Align the white dot on the cuff with the center of your arm. I will give you a few seconds to get that done." withSynthesizer:synthesizer];
    [self performSelector:@selector(NextAudio) withObject:nil afterDelay:32.0];

    self.startButtonImageView.image =  [UIImage animatedImageNamed:@"StartButton-" duration:1.0f];
//"Place both feet flat on the floor and rest your arms comfortably. Please remember to remove constricting clothing. Push the start button on the blood pressure machine when you are ready. Please hold still and do not move or talk."
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    
    [[UIDevice currentDevice] setValue:@(UIInterfaceOrientationPortrait) forKey:@"orientation"];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.bpDevice connectWithTimeout:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.bpDevice disconnect];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}

- (void)NextAudio
{
    [AudioPlayer speak:@"Place both feet flat on the floor and rest your arms comfortably. Please remember to remove or adjust constricting clothing. Push the start button firmly on the blood pressure machine when you are ready. Please hold still and do not move or talk." withSynthesizer:synthesizer];
    
}

- (void)saveBloodPressure
{
    MBProgressHUD *hud = [Utility getHUDAddedTo:self.navigationController.view withText:NSLocalizedString(@"Saving...", nil)];
    [hud show:YES];
    
    [[UserManager sharedManager]saveBloodPressureMeasurement:currentBloodPressure completion:^(NSError *error) {
        [hud hide:YES];
        
        if (error == nil)
        {
            [[HealthKitManager sharedManager] saveBloodPressure:currentBloodPressure];
            [self completeBloodPressure];
        }
        else
        {
            if ([[DbManager sharedManager] insertBloodPressureMeasurement:currentBloodPressure])
            {
                //[[HealthKitManager sharedManager] saveBloodPressure:currentBloodPressure];
                [self completeBloodPressure];
            }
            else
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
                                                                               message:NSLocalizedString(@"Please make sure you have a stable internet connection.", nil)
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [alert dismissViewControllerAnimated:YES completion:nil];
                }];
                
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
    }];
}

- (void)authenticate
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Transmit Readings" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    
    NSMutableAttributedString *alertText = [[NSMutableAttributedString alloc] initWithString:@"Thank you!\n\nPlease push the OK button to transmit your readings to your healthcare team. We will be in touch with you if any changes are needed."];
    [alertText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,[alertText length])];
    
    [alertText addAttribute:NSFontAttributeName
                      value:[UIFont systemFontOfSize:22.0]
                      range:NSMakeRange(0,[alertText length])];
    
    [alert setValue:alertText forKey:@"attributedTitle"];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action){
                                                   [self saveBloodPressure];
                                                   [alert dismissViewControllerAnimated:YES completion:nil];                                                   }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showPasswordAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Enter Passcode", nil)
                                                                   message:NSLocalizedString(@"Transmit readings to your healthcare team", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Passcode";
        textField.secureTextEntry = YES;
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *passcode = alert.textFields.firstObject;
        NSString *pin = [JNKeychain loadValueForKey:@"pin"];
        
        if ([passcode.text isEqualToString:pin])
        {
            [self saveBloodPressure];
        }
        else
        {
            [self showPasswordAlert];
        }
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)completeBloodPressure
{
    self.bpAttempt++;
    
    if (self.bpAttempt > 1)
    {
        self.instructionsLabel.text = @"You may now remove the blood pressure cuff";
        [AudioPlayer speak:@"You may now remove the blood pressure cuff" withSynthesizer:synthesizer];
    }
    else
    {
        if (self.bpAttempt == 2)
        {
            self.bpSecondsRemaining = 300;
        }
        else
        {
            self.bpSecondsRemaining = 120;
        }
        
        self.timerStartDate = [NSDate date];
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkDidTimeout) userInfo:nil repeats:YES];
        
        NSInteger minutes = (self.bpSecondsRemaining % 3600) / 60;
        [AudioPlayer speak:[NSString stringWithFormat:NSLocalizedString(@"Please wait %d minutes and retake your blood pressure", nil), minutes] withSynthesizer:synthesizer];
    }
}

- (void)checkDidTimeout
{
    if (self.timerStartDate != nil)
    {
        NSDate *date = [NSDate date];
        NSTimeInterval interval = [date timeIntervalSinceDate:self.timerStartDate];
        
        if (interval > self.bpSecondsRemaining - 1)
        {
            [self.timer invalidate];
            self.timer = nil;
            self.timerStartDate = nil;
            self.instructionsLabel.text = NSLocalizedString(@"Push the START button on the blood pressure machine.  Please hold still, do not move or talk", nil);
            
            if (self.bpAttempt == 3)
            {
                [AudioPlayer speak:@"It's time to take your final blood pressure.  Please sit down and relax.  Place the blood pressure cuff securely on your upper arm.  Place both feet flat on the floor and rest your arms comfortably.  Push the start button on the blood pressure machine.  Please hold still and do not move or talk." withSynthesizer:synthesizer];
            }
            else
            {
                [AudioPlayer speak:@"It's time to take your next blood pressure.  Please sit down and relax.  Place the blood pressure cuff securely on your upper arm.  Place both feet flat on the floor and rest your arms comfortably.  Push the start button on the blood pressure machine.  Please hold still and do not move or talk." withSynthesizer:synthesizer];
            }
            
            self.bpInProgress = YES;
            [self.bpDevice connectWithTimeout:0];
        }
        else
        {
            NSInteger secondsRemaining = self.bpSecondsRemaining - interval;
            NSInteger minutes = (secondsRemaining % 3600) / 60;
            NSInteger seconds = (secondsRemaining % 3600) % 60;
            self.instructionsLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Please wait %d:%02d minutes and retake your blood pressure", nil), minutes, seconds];
        }
    }
}

- (void)deviceDidConnect
{
    
}

- (void)deviceDidFailToConnect
{
    if (self.bpInProgress)
    {
        [self.bpDevice connectWithTimeout:0];
    }
}

- (void)deviceDidDisconnect
{
    if (self.bpInProgress)
    {
        [self.bpDevice connectWithTimeout:0];
    }
    else
    {
        if (currentBloodPressure != nil)
        {
            if ((currentBloodPressure.systolic.intValue == 255 && currentBloodPressure.diastolic.intValue == 255) || currentBloodPressure.pulse.intValue >= 224)
            {
                self.instructionsLabel.text = NSLocalizedString(@"Please check the cuff placement and try again", nil);
                self.bpInProgress = YES;
                [AudioPlayer speak:@"Please check the cuff placement and try again" withSynthesizer:synthesizer];
                [self.bpDevice connectWithTimeout:0];
            }
            else
            {
                self.systolicLabel.text = [NSString stringWithFormat:@"%d", currentBloodPressure.systolic.intValue];
                self.diastolicLabel.text = [NSString stringWithFormat:@"%d", currentBloodPressure.diastolic.intValue];
                self.pulseLabel.text = [NSString stringWithFormat:@"%d", currentBloodPressure.pulse.intValue];
                self.startButtonImageView.hidden =YES;
                self.systolicView.hidden = NO;
                self.diastolicView.hidden = NO;
                self.pulseView.hidden = NO;
                [AudioPlayer speak:[NSString stringWithFormat:NSLocalizedString(@"Your blood pressure is %d over %d with a heart rate of %d beats per minute.", nil),
                                    currentBloodPressure.systolic.intValue,
                                    currentBloodPressure.diastolic.intValue,
                                    currentBloodPressure.pulse.intValue] withSynthesizer:synthesizer];
                [self authenticate];
            }
        }
    }
}

- (void)deviceDidTimeout
{
    
}

- (void)gotReading:(id)reading
{
    if ([reading isKindOfClass:[BloodPressureMeasurement class]])
    {
        currentBloodPressure = (BloodPressureMeasurement *)reading;
        self.startButtonImageView.hidden =YES;
        self.instructionsLabel.text = @"Please wait...";
        self.bpInProgress = NO;
        
        if (!self.stopSpeaking)
        {
            [AudioPlayer speak:@"Please wait..." withSynthesizer:synthesizer];
            self.stopSpeaking = YES;
        }
    }
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    if (self.timerStartDate != nil)
    {
        NSDate *date = [NSDate date];
        NSTimeInterval interval = [date timeIntervalSinceDate:self.timerStartDate];
        
        UILocalNotification *reminder = [UILocalNotification new];
        reminder.timeZone = [NSCalendar currentCalendar].timeZone;
        reminder.fireDate = [[NSDate date] dateByAddingTimeInterval:(self.bpSecondsRemaining - interval)];
        reminder.alertBody = NSLocalizedString(@"It's time to take your blood pressure!", nil);
        reminder.userInfo = @{@"uid" : @"bpreminder"};
        reminder.soundName = @"bpreminder.m4a";
        [[UIApplication sharedApplication] scheduleLocalNotification:reminder];
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
//    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
//    for (UILocalNotification *notification in notifications)
//    {
//        if ([[notification.userInfo valueForKey:@"uid"] isEqualToString:@"bpreminder"])
//        {
//            [[UIApplication sharedApplication] cancelLocalNotification:notification];
//        }
//    }
//    
//    [self checkDidTimeout];
    
    if (self.bpInProgress)
    {
        [self.bpDevice connectWithTimeout:0];
    }
}

@end
