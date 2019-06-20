//
//  CompletionVC.m
//  HeartValve
//
//  Created by Jonathan on 11/2/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "CompletionVC.h"
#import <LocalAuthentication/LocalAuthentication.h>
#import <AVFoundation/AVFoundation.h>
#import "AudioPlayer.h"
#import "Utility.h"
#import "UIColor+Extensions.h"
#import "AppDelegate.h"
#import "JNKeychain.h"

@implementation CompletionVC
{
    AVSpeechSynthesizer *synthesizer;
    NSString *audio;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    synthesizer = [AVSpeechSynthesizer new];
    [[self.exitButton layer] setBorderWidth:1.0f];
    [[self.exitButton layer] setBorderColor:[UIColor appBlueColor].CGColor];
    [self.exitButton setBackgroundImage:[Utility imageWithColor:[UIColor appYellowColor]] forState:UIControlStateHighlighted];
    self.exitButton.hidden = YES;
    self.feedbackView.hidden = NO;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate updateDailyAssessmentWithStep:6];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self authenticate];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [NSString stringWithFormat:@"Report"];
    audio = @"Thank you! You have completed your daily assessment. Please push the OK button to transmit your readings to your healthcare team.  We will be in touch with you if any changes are needed.  Please return your device to the charger.  Have a wonderful day!";
    [AudioPlayer speak:audio withSynthesizer:synthesizer];
}

- (void)authenticate
{

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Transmit Readings" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    
    NSMutableAttributedString *alertText = [[NSMutableAttributedString alloc] initWithString:@"Thank you! You have completed your daily assessment.\n\nPlease push the OK button to transmit your readings to your healthcare team. We will be in touch with you if any changes are needed.\n\nPlease return your device to the charger.\n\nHave a wonderful day!"];
    [alertText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,[alertText length])];

    [alertText addAttribute:NSFontAttributeName
                  value:[UIFont systemFontOfSize:22.0]
                  range:NSMakeRange(0,[alertText length])];

    [alert setValue:alertText forKey:@"attributedTitle"];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
                                                               [self finish];
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
            [self finish];
        }
        else
        {
            [self showPasswordAlert];
        }
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)finish
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate transmitLocalStorage];
    
    self.feedbackView.hidden = NO;
    [self performSelector:@selector(ExitApp) withObject:nil afterDelay:12.0];
}

- (void)ExitApp
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate updateDailyAssessmentWithStep:0];
    [appDelegate setDefaultViewController];
    exit(0);
    
}

- (IBAction)replayAudio:(id)sender
{
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    synthesizer = [AVSpeechSynthesizer new];
    [AudioPlayer speak:audio withSynthesizer:synthesizer];
}

- (IBAction)exit:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate updateDailyAssessmentWithStep:0];
    [appDelegate setDefaultViewController];
    exit(0);
}

@end
