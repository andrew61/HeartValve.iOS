//
//  BloodPressureManualVC.m
//  MyHealthApp
//
//  Created by Jonathan on 1/14/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "BloodPressureManualVC.h"
#import "BloodPressureMeasurement.h"
#import "UserManager.h"
#import "MBProgressHUD.h"
#import "UIColor+HexValue.h"
#import "DbManager.h"
#import "HealthKitManager.h"
#import "UIColor+Extensions.h"
#import "UIFont+Extensions.h"

@implementation BloodPressureManualVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveBloodPressure:)];
    self.parentViewController.navigationItem.rightBarButtonItem = saveButton;
    self.parentViewController.navigationItem.rightBarButtonItem.tintColor = [UIColor appYellowColor];
    self.parentViewController.navigationItem.rightBarButtonItem.enabled = NO;
    
    [self.parentViewController.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
                                                           NSFontAttributeName : [UIFont appFontBold:18]
                                                           }
                                                forState:UIControlStateHighlighted];
    [self.parentViewController.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
                                                           NSFontAttributeName : [UIFont appFontBold:18]
                                                           }
                                                forState:UIControlStateNormal];
    [self.parentViewController.navigationItem.rightBarButtonItem setTitleTextAttributes:@{
                                                           NSFontAttributeName : [UIFont appFontBold:18]
                                                           }
                                                forState:UIControlStateDisabled];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.parentViewController.navigationItem.rightBarButtonItem = nil;
}

- (IBAction)saveBloodPressure:(id)sender
{
    BloodPressureMeasurement *measurement = [BloodPressureMeasurement new];
    measurement.systolic = [NSNumber numberWithInt:[self.systolicText.text intValue]];
    measurement.diastolic = [NSNumber numberWithInt:[self.diastolicText.text intValue]];
    measurement.map = [NSNumber numberWithInt:[self.mapText.text intValue]];
    measurement.pulse = [NSNumber numberWithInt:[self.pulseText.text intValue]];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = NSLocalizedString(@"Saving...", nil);
    hud.color = [UIColor appYellowColor];
    hud.dimBackground = YES;
    hud.removeFromSuperViewOnHide = YES;
    [hud show:YES];
    
    [[UserManager sharedManager]saveBloodPressureMeasurement:measurement completion:^(NSError *error) {
        [hud hide:YES];
        
        if (error == nil)
        {
            [[HealthKitManager sharedManager] saveBloodPressure:measurement];
            [self completeBloodPressure];
        }
        else
        {
            if ([[DbManager sharedManager] insertBloodPressureMeasurement:measurement])
            {
                [[HealthKitManager sharedManager] saveBloodPressure:measurement];
                [self completeBloodPressure];
            }
            else
            {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Save Failed!", nil)
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

- (void)completeBloodPressure
{
    self.parentViewController.navigationItem.rightBarButtonItem.enabled = NO;
    self.systolicText.text = nil;
    self.diastolicText.text = nil;
    self.mapText.text = nil;
    self.pulseText.text = nil;
    [self hideKeyboard:nil];
}

- (IBAction)editingChanged:(id)sender
{
    if ([self.systolicText.text length] != 0 &&
        [self.diastolicText.text length] != 0 &&
        [self.mapText.text length] != 0 &&
        [self.pulseText.text length] != 0)
    {
        [self.parentViewController.navigationItem.rightBarButtonItem setEnabled:YES];
    }
    else
    {
        [self.parentViewController.navigationItem.rightBarButtonItem setEnabled:NO];
    }
}

- (void)hideKeyboard:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.view endEditing:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellId = cell.reuseIdentifier;
    
    if ([cellId isEqualToString:@"SystolicCell"])
    {
        [self.systolicText becomeFirstResponder];
    }
    else if ([cellId isEqualToString:@"DiastolicCell"])
    {
        [self.diastolicText becomeFirstResponder];
    }
    else if ([cellId isEqualToString:@"MapCell"])
    {
        [self.mapText becomeFirstResponder];
    }
    else if ([cellId isEqualToString:@"PulseCell"])
    {
        [self.pulseText becomeFirstResponder];
    }
}

@end