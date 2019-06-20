//
//  WeightVC.m
//  MyHealthApp
//
//  Created by Jonathan on 1/5/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "WeightVC.h"
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
#import <LocalAuthentication/LocalAuthentication.h>
#import "JNKeychain.h"

@implementation WeightVC
{
    WeightMeasurement *currentWeight;
    AVSpeechSynthesizer *synthesizer;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.scaleDevice = [[AD_UC_352BLE alloc] initWithDelegate:self];
    synthesizer = [AVSpeechSynthesizer new];
    self.weightInProgress = YES;
    self.weightView.hidden = YES;
    self.instructionsLabel.text = @"Please remove footwear and step carefully onto the scale with both feet. Please hold still and do not move or talk. Step off the scale when you hear  two beeps.";
    [AudioPlayer speak:@"Please remove footwear and step carefully onto the scale with both feet. Please hold still and do not move or talk. Step off the scale when you hear  two beeps." withSynthesizer:synthesizer];
    
//    NSMutableArray *animatedImagesArray = [[NSMutableArray alloc] initWithObjects:[UIImage imageNamed:@"ScaleStep-1.png"], [UIImage imageNamed:@"ScaleStep-2.png"], [UIImage imageNamed:@"ScaleStep-3.png"], [UIImage imageNamed:@"ScaleStep-4.png"], [UIImage imageNamed:@"ScaleStep-5.png"], [UIImage imageNamed:@"ScaleStep-6.png"], [UIImage imageNamed:@"ScaleStep-7.png"], [UIImage imageNamed:@"ScaleStep-8.png"], nil];
//    self.weightImageView.animationImages = animatedImagesArray;
//    self.weightImageView.animationRepeatCount = 1;
//    self.weightImageView.animationDuration = 1.8f;
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

- (void)saveWeight
{
    MBProgressHUD *hud = [Utility getHUDAddedTo:self.navigationController.view withText:NSLocalizedString(@"Saving...", nil)];
    [hud show:YES];
    
    [[UserManager sharedManager]saveWeightMeasurement:currentWeight completion:^(NSError *error) {
        [hud hide:YES];
        
        if (error == nil)
        {
            [[HealthKitManager sharedManager] saveWeight:currentWeight];
            [self completeWeight];
        }
        else
        {
            if ([[DbManager sharedManager] insertWeightMeasurement:currentWeight])
            {
                //[[HealthKitManager sharedManager] saveWeight:currentWeight];
                [self completeWeight];
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
                                                   [self saveWeight];
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
            [self saveWeight];
            
            self.instructionsLabel.text = @"Your weight was successfully submitted.";

        }
        else
        {
            [self showPasswordAlert];
        }
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)completeWeight
{
    [AudioPlayer speak:@"Your weight was successfully submitted." withSynthesizer:synthesizer];
    self.instructionsLabel.text = @"Your weight was successfully submitted.";
    self.weightInProgress = YES;
    self.weightImageView.hidden =YES;
    [self.scaleDevice connectWithTimeout:0];
}

- (void)deviceDidConnect
{
 
    
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
            self.weightImageView.hidden =YES;
            self.weightView.hidden = NO;
            [self authenticate];
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
        
        if (!self.stopSpeaking)
        {
            [AudioPlayer speak:@"Please wait..." withSynthesizer:synthesizer];
            self.stopSpeaking = YES;
        }
    }
}

@end
