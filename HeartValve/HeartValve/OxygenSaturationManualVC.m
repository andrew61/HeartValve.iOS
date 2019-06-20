//
//  OxygenSaturationManualVC.m
//  HeartValve
//
//  Created by Jonathan on 10/11/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "OxygenSaturationManualVC.h"
#import "OxygenSaturation.h"
#import "UserManager.h"
#import "MBProgressHUD.h"
#import "UIColor+HexValue.h"
#import "DbManager.h"
#import "HealthKitManager.h"
#import "UIColor+Extensions.h"
#import "UIFont+Extensions.h"
#import "Utility.h"

@implementation OxygenSaturationManualVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveOxygenSaturation:)];
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

- (IBAction)saveOxygenSaturation:(id)sender
{
    OxygenSaturation *measurement = [OxygenSaturation new];
    measurement.spO2 = [NSNumber numberWithDouble:[self.spO2Text.text doubleValue]];
    measurement.heartRate = [NSNumber numberWithInt:[self.heartRateText.text intValue]];
    
    MBProgressHUD *hud = [Utility getHUDAddedTo:self.navigationController.view withText:NSLocalizedString(@"Saving...", nil)];
    [hud show:YES];
    
    [[UserManager sharedManager] saveOxygenSaturation:measurement completion:^(NSError *error) {
        [hud hide:YES];
        
        if (error == nil)
        {
            [[HealthKitManager sharedManager] saveOxygenSaturation:measurement];
            [self completeOxygenSaturation];
        }
        else
        {
            if ([[DbManager sharedManager] insertOxygenSaturation:measurement])
            {
                [[HealthKitManager sharedManager] saveOxygenSaturation:measurement];
                [self completeOxygenSaturation];
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

- (void)completeOxygenSaturation
{
    self.parentViewController.navigationItem.rightBarButtonItem.enabled = NO;
    self.spO2Text.text = nil;
    self.heartRateText.text = nil;
    [self hideKeyboard:nil];
}

- (IBAction)editingChanged:(id)sender
{
    if ([self.spO2Text.text length] != 0 &&
        [self.heartRateText.text length] != 0)
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
    
    if ([cellId isEqualToString:@"SpO2Cell"])
    {
        [self.spO2Text becomeFirstResponder];
    }
    else if ([cellId isEqualToString:@"HeartRateCell"])
    {
        [self.heartRateText becomeFirstResponder];
    }
}

@end
