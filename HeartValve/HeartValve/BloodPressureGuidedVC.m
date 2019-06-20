//
//  BloodPressureGuidedVC.m
//  HeartValve
//
//  Created by Jonathan on 11/2/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "BloodPressureGuidedVC.h"
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
#import "AppDelegate.h"

@interface BloodPressureGuidedVC ()

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *timerStartDate;

@end

@implementation BloodPressureGuidedVC
{
    BloodPressureMeasurement *currentBloodPressure;
    AVSpeechSynthesizer *synthesizer;
    NSString *audio;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bpDevice = [[AD_UA_651BLE alloc] initWithDelegate:self];
    self.bpAttempt = 1;
    synthesizer = [AVSpeechSynthesizer new];
    self.bpInProgress = YES;
    self.systolicView.hidden = YES;
    self.diastolicView.hidden = YES;
    self.pulseView.hidden = YES;
    [[self.continueButton layer] setBorderWidth:1.0f];
    [[self.continueButton layer] setBorderColor:[UIColor appBlueColor].CGColor];
    [self.continueButton setBackgroundImage:[Utility imageWithColor:[UIColor appYellowColor]] forState:UIControlStateHighlighted];
    self.continueButton.hidden = YES;
    self.instructionsLabel.text = NSLocalizedString(@"Push the START button on the blood pressure machine.  Please hold still, do not move or talk", nil);
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate updateDailyAssessmentWithStep:4];
    
    audio = @"Please sit down and relax. Place the blood pressure cuff securely on your bear upper arm. The bottom of the cuff should be a half inch above your elbow. Align the white dot on the cuff with the center of your arm. I will give you a few seconds to get that done.";
    [AudioPlayer speak:audio withSynthesizer:synthesizer];
    [self performSelector:@selector(NextAudio) withObject:nil afterDelay:32.0];

    
    self.startButtonImageView.image =  [UIImage animatedImageNamed:@"StartButton-" duration:1.0f];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
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

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (void)saveBloodPressure
{
    //save to health kit
    [[HealthKitManager sharedManager] saveBloodPressure:currentBloodPressure];
    
    //save to Tachl
    [[UserManager sharedManager] saveBloodPressureMeasurement:currentBloodPressure completion:^(NSError *error) {
        
        // If error occurs save currentBloodPressure into local DB.
        if (error != nil)
        {
            if ([[DbManager sharedManager] insertBloodPressureMeasurement:currentBloodPressure])
            {
                [self completeBloodPressure];
            }
            else
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil)
                                                                               message:NSLocalizedString(@"Please make sure you have a stable internet connection.", nil)
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                    [self performSelector:@selector(NextAssessment) withObject:nil afterDelay:1.0];
                    [alert dismissViewControllerAnimated:YES completion:^{}];
                }];
                
                [alert addAction:ok];
                [self presentViewController:alert animated:YES completion:nil];
            }
        }
        else{
            [self completeBloodPressure];
        }
    }];

}

- (void)completeBloodPressure
{
    self.bpAttempt++;
    
    if (self.bpAttempt > 1)
    {
        self.resetButton.hidden = YES;
//        self.continueButton.hidden = NO;
        self.instructionsLabel.text = @"You may now remove the blood pressure cuff";
        audio = @"You may now remove the blood pressure cuff.";
        [AudioPlayer speak:audio withSynthesizer:synthesizer];
        [self performSelector:@selector(NextAssessment) withObject:nil afterDelay:16.0];

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
        audio = [NSString stringWithFormat:NSLocalizedString(@"Please wait %d minutes and retake your blood pressure", nil), minutes];
        [AudioPlayer speak:audio withSynthesizer:synthesizer];
    }
}
- (void)NextAudio
{
    [AudioPlayer speak:@"Place both feet flat on the floor and rest your arms comfortably. Please remember to remove or adjust constricting clothing. Push the start button firmly on the blood pressure machine when you are ready. Please hold still and do not move or talk." withSynthesizer:synthesizer];
    
}
- (void)NextAssessment
{
//    [self performSegueWithIdentifier:@"GoToOxygenSaturation" sender:nil];
    UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"CompletionVC"];
    [self showViewController:vc sender:self];
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
            self.instructionsLabel.text = NSLocalizedString(@"Push the START button on the blood pressure machine.  Please hold still, do not move or talk.", nil);

            
            if (self.bpAttempt == 3)
            {
                audio = @"It's time to take your final blood pressure.  Please sit down and relax.  Place the blood pressure cuff securely on your upper arm.  Place both feet flat on the floor and rest your arms comfortably.  Push the start button on the blood pressure machine.  Please hold still and do not move or talk.";
                [AudioPlayer speak:audio withSynthesizer:synthesizer];
            }
            else
            {
                audio = @"It's time to take your next blood pressure.  Please sit down and relax.  Place the blood pressure cuff securely on your upper arm.  Place both feet flat on the floor and rest your arms comfortably.  Push the start button on the blood pressure machine.  Please hold still and do not move or talk.";
                [AudioPlayer speak:audio withSynthesizer:synthesizer];
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
        NSLog(@"deviceDidFailToConnect tothe BPM 2");

    }
    NSLog(@"deviceDidFailToConnect out");

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
                audio = @"Please check the cuff placement and try again";
                [AudioPlayer speak:audio withSynthesizer:synthesizer];
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
                audio = [NSString stringWithFormat:NSLocalizedString(@"Your blood pressure is %d over %d with a heart rate of %d beats per minute.", nil),
                         currentBloodPressure.systolic.intValue,
                         currentBloodPressure.diastolic.intValue,
                         currentBloodPressure.pulse.intValue];
                [AudioPlayer speak:audio withSynthesizer:synthesizer];
                [self saveBloodPressure];
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
        
        if(!self.stopSpeaking)
        {
            audio = @"Please wait...";
            [AudioPlayer speak:audio withSynthesizer:synthesizer];
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
    NSArray *notifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notification in notifications)
    {
        if ([[notification.userInfo valueForKey:@"uid"] isEqualToString:@"bpreminder"])
        {
            [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
    
    [self checkDidTimeout];
    
    if (self.bpInProgress)
    {
        [self.bpDevice connectWithTimeout:0];
    }
}

- (IBAction)replayAudio:(id)sender
{
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    synthesizer = [AVSpeechSynthesizer new];
    [AudioPlayer speak:audio withSynthesizer:synthesizer];
    [self performSelector:@selector(NextAudio) withObject:nil afterDelay:32.0];
}

- (IBAction)reset:(id)sender
{
    [self.bpDevice connectWithTimeout:0];
}

@end
