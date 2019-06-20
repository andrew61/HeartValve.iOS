//
//  MeasurementsVC.m
//  MUSCMedPlan
//
//  Created by Jonathan on 7/25/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "MeasurementsVC.h"
#import "HealthKitManager.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"


@implementation MeasurementsVC

-(void)viewDidLoad: (BOOL)animated
{
    self.tableView.delegate = self;

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    if (self.revealViewController)
//    {
//        [self.view addGestureRecognizer:self.revealViewController.panGestureRecognizer];
//    }
    
    self.parentViewController.navigationItem.title = @"Measurements";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[HealthKitManager sharedManager] requestAuthorization:^{
        [self updateHKImages];
    }];
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    /// User clicks 
    if (1 == indexPath.section && 0 == indexPath.row) {
        
        NSLog(@"I'm clicking here jameson.");
        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate updateDailyAssessmentForRetake:1 with:[NSDate date]];
        [appDelegate setDefaultViewController];

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
    
    if ([[HealthKitManager sharedManager] isAuthorizedForOxygenSaturation])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.oxygenSaturationHKImage.image = [UIImage imageNamed:@"health-icon.png"];
        });
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.oxygenSaturationHKImage.image = nil;
        });
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self updateHKImages];
}

@end
