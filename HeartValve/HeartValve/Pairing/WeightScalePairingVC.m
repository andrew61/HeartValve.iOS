//
//  WeightScalePairingVC.m
//  HeartValve
//
//  Created by Jameson B on 10/31/17.
//  Copyright © 2017 MUSC. All rights reserved.
//

#import "WeightScalePairingVC.h"
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

@interface WeightScalePairingVC ()

@end

@implementation WeightScalePairingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.scaleDevice = [[AD_UC_352BLE alloc] initWithDelegate:self];

}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.scaleDevice disconnect];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
 
}
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.scaleDevice connectWithTimeout:0];
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

- (void)deviceDidConnect
{
    
}

- (void)deviceDidFailToConnect
{

}

- (void)deviceDidDisconnect
{
  
}

- (void)deviceDidTimeout
{
    
}

- (void)gotReading:(id)reading {
    
}
@end
