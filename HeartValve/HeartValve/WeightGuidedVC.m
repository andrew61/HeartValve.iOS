//
//  WeightGuidedVC.m
//  HeartValve
//
//  Created by Jonathan on 11/2/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "WeightGuidedVC.h"
#import "WeightMeasurement.h"
#import "AD_UC_352BLE.h"
#import "UserManager.h"
#import "MBProgressHUD.h"
#import "UIColor+HexValue.h"
#import "DbManager.h"
#import "HealthKitManager.h"
#import "UIColor+Extensions.h"
#import "UIFont+Extensions.h"
#import "Utility.h"
#import <AVFoundation/AVFoundation.h>
#import "AudioPlayer.h"
#import "AppDelegate.h"
#import "JNKeychain.h"


@implementation WeightGuidedVC
{
    WeightMeasurement *currentWeight;
    AVSpeechSynthesizer *synthesizer;
    NSString *audio;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scaleDevice = [[AD_UC_352BLE alloc] initWithDelegate:self];
    synthesizer = [AVSpeechSynthesizer new];
    self.weightInProgress = YES;
    self.weightView.hidden = YES;
    [[self.continueButton layer] setBorderWidth:1.0f];
    [[self.continueButton layer] setBorderColor:[UIColor appBlueColor].CGColor];
    [self.continueButton setBackgroundImage:[Utility imageWithColor:[UIColor appYellowColor]] forState:UIControlStateHighlighted];
    self.continueButton.hidden = YES;
    self.instructionsLabel.text = @"Please remove footwear and step carefully onto the scale with both feet. Please hold still and do not move or talk. Step off the scale when you hear  two beeps.";
    self.stopSpeaking = NO;
//    self.weightImageView.image =  [UIImage animatedImageNamed:@"ScaleStep-" duration:1.5f];
    
//    NSMutableArray *animatedImagesArray = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"ScaleStep-1.png"], [UIImage imageNamed:@"ScaleStep-2.png"], [UIImage imageNamed:@"ScaleStep-3.png"], [UIImage imageNamed:@"ScaleStep-4.png"], [UIImage imageNamed:@"ScaleStep-5.png"], [UIImage imageNamed:@"ScaleStep-6.png"], [UIImage imageNamed:@"ScaleStep-7.png"], [UIImage imageNamed:@"ScaleStep-8.png"], nil];
//    self.weightImageView.animationImages = animatedImagesArray;
//    self.weightImageView.animationRepeatCount = 1;
//    self.weightImageView.animationDuration = 1.8f;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate updateDailyAssessmentWithStep:3];
    
    audio = @"Please remove footwear and step carefully onto the scale with both feet. Please hold still and do not move or talk. Step off the scale when you hear two beeps.";
    [AudioPlayer speak:audio withSynthesizer:synthesizer];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    [self.weightImageView startAnimating];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.scaleDevice connectWithTimeout:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.scaleDevice disconnect];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    //If you don't want to support multiple orientations uncomment the line below
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
    //return [super shouldAutorotateToInterfaceOrientation:toInterfaceOrientation];
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (void)saveWeight
{
    //save to health kit
    [[HealthKitManager sharedManager] saveWeight:currentWeight];
    
    //save to Tachl
    [[UserManager sharedManager] saveWeightMeasurement:currentWeight completion:^(NSError *error) {
        
        // If error occurs save weight into local DB.
        if (error != nil)
        {
            if ([[DbManager sharedManager] insertWeightMeasurement:currentWeight])
            {
                [self completeWeight];
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
            [self completeWeight];
        }
    }];
    
}

- (void)completeWeight
{
    self.instructionsLabel.text = @"Carefully step onto the scale.  Do not move or talk.";
    self.weightInProgress = YES;
    self.weightImageView.hidden =YES;
    self.resetButton.hidden = YES;
    self.continueButton.hidden = YES;
    [self.scaleDevice connectWithTimeout:0];
    audio = @"Thank you! Please find a comfortable place to sit for the next part of your daily survey.";
    [AudioPlayer speak:audio withSynthesizer:synthesizer];
    
    [self performSelector:@selector(NextAssessment) withObject:nil afterDelay:12.0];

}

- (void)deviceDidConnect
{
    
}

- (void)NextAssessment
{
    [JNKeychain saveValue:@"true" forKey:@"isDailyAssessmentSurvey"];

    [self performSegueWithIdentifier:@"GoToSurveyQuestion" sender:nil];
    
}

- (void)deviceDidFailToConnect
{
    if (self.weightInProgress)
    {
        [self.scaleDevice connectWithTimeout:0];
    }
}

- (void)deviceDidDisconnect
{
    if (self.weightInProgress)
    {
        [self.scaleDevice connectWithTimeout:0];
    }
    else
    {
        if (currentWeight != nil)
        {
            self.weightLabel.text = [NSString stringWithFormat:@"%.1f", currentWeight.weight.floatValue];
            self.weightView.hidden = NO;
            [self saveWeight];
        }
    }
}

- (void)deviceDidTimeout
{
    
}

- (void)gotReading:(id)reading
{

    if ([reading isKindOfClass:[WeightMeasurement class]])
    {
        currentWeight = (WeightMeasurement *)reading;
        self.instructionsLabel.text = @"Please wait...";
        self.weightInProgress = NO;
        
        if(!self.stopSpeaking)
        {
            audio = @"Please wait...";
            [AudioPlayer speak:audio withSynthesizer:synthesizer];
            self.stopSpeaking = YES;
        }
    }
}

- (IBAction)replayAudio:(id)sender
{
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    synthesizer = [AVSpeechSynthesizer new];
    [AudioPlayer speak:audio withSynthesizer:synthesizer];
}

- (IBAction)reset:(id)sender
{
    [self.scaleDevice connectWithTimeout:0];
}

@end
