//
//  WelcomeVC.m
//  HeartValve
//
//  Created by Jonathan on 11/2/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "WelcomeVC.h"
#import "UIColor+Extensions.h"
#import "Utility.h"
#import "AudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "UserManager.h"
#import "User.h"
#import "Utility.h"
#import "MBProgressHUD.h"
#import "HealthKitManager.h"
#import "AppDelegate.h"
#import "JNKeychain.h"


@implementation WelcomeVC
{
    AVSpeechSynthesizer *synthesizer;
    NSString *welcomeText;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
//    [[self.dailyAssessmentButton layer] setBorderWidth:1.0f];
//    [[self.dailyAssessmentButton layer] setBorderColor:[UIColor appBlueColor].CGColor];
    [self.dailyAssessmentButton setBackgroundImage:[Utility imageWithColor:[UIColor appYellowColor]] forState:UIControlStateHighlighted];
    
    self.welcomeLabel.hidden = YES;
    self.dailyAssessmentButton.hidden = YES;
    
    synthesizer = [AVSpeechSynthesizer new];
    
//    MBProgressHUD *hud = [Utility getHUDAddedTo:self.view withText:@"Loading..."];
//    [hud show:YES];
    NSString *firstName = [JNKeychain loadValueForKey:@"UserFirstName"];

            if ([firstName isEqualToString:@"NoName"])
            {
                welcomeText = @"Hello! It's time to start your daily assessment.  This process should take less than 10 minutes.  Press the start button on your screen to get started.";
                //[AudioPlayer speak:@"Hello!  It's time to start your daily assessment.  This process should take less than 10 minutes.  Press the button on your screen to get started." withSynthesizer:synthesizer];
            }
            else
            {
                self.welcomeLabel.text = [NSString stringWithFormat:@"Welcome\n%@", firstName];
                welcomeText = [NSString stringWithFormat:@"Hello %@!  It's time to start your daily assessment.  This process should take less than 10 minutes.  Press the start button on your screen to get started.", firstName];
                //[AudioPlayer speak:[NSString stringWithFormat:@"Hello %@!  It's time to start your daily assessment.  This process should take less than 10 minutes.  Press the button on your screen to get started.", user.firstName] withSynthesizer:synthesizer];
            }
    
        
        [AudioPlayer speak:welcomeText withSynthesizer:synthesizer];
        
        self.welcomeLabel.hidden = NO;
        self.dailyAssessmentButton.hidden = NO;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[HealthKitManager sharedManager] requestAuthorization:nil];
    [self checkApplicationVersion]; ///Checks for app version and updates.

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}


- (IBAction)replayAudio:(id)sender
{
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    synthesizer = [AVSpeechSynthesizer new];
    [AudioPlayer speak:welcomeText withSynthesizer:synthesizer];
}

- (void)checkApplicationVersion
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.updateAvailable)
    {
        NSString *name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Update Available", nil) message:[NSString stringWithFormat:NSLocalizedString(@"A new version of %@ is available. Please update now?", nil), name] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *update = [UIAlertAction actionWithTitle:NSLocalizedString(@"Update", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [appDelegate updateApplication];
        }];

        
        [alert addAction:update];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

@end
