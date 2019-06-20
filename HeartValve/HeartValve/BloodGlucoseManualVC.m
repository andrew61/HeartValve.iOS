//
//  BloodGlucoseManualVC.m
//  MyHealthApp
//
//  Created by Jonathan on 1/15/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "BloodGlucoseManualVC.h"
#import "BloodGlucoseMeasurement.h"
#import "UserManager.h"
#import "MBProgressHUD.h"
#import "UIColor+HexValue.h"
#import "DbManager.h"
#import "HealthKitManager.h"
#import "UIColor+Extensions.h"
#import "UIFont+Extensions.h"

@implementation BloodGlucoseManualVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.tableView addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    UIBarButtonItem *saveButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveBloodGlucose:)];
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

- (void)saveBloodGlucose:(id)sender
{
    BloodGlucoseMeasurement *measurement = [BloodGlucoseMeasurement new];
    measurement.glucoseLevel = [NSNumber numberWithInt:[self.glucoseLevelText.text intValue]];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = NSLocalizedString(@"Saving...", nil);
    hud.color = [UIColor appYellowColor];
    hud.dimBackground = YES;
    hud.removeFromSuperViewOnHide = YES;
    [hud show:YES];
    
    [[UserManager sharedManager]saveBloodGlucoseMeasurement:measurement completion:^(NSError *error) {
        [hud hide:YES];
        
        if (error == nil)
        {
            [[HealthKitManager sharedManager] saveBloodGlucose:measurement];
            [self completeBloodGlucose];
        }
        else
        {
            if ([[DbManager sharedManager] insertBloodGlucoseMeasurement:measurement])
            {
                [[HealthKitManager sharedManager] saveBloodGlucose:measurement];
                [self completeBloodGlucose];
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

- (void)completeBloodGlucose
{
    self.parentViewController.navigationItem.rightBarButtonItem.enabled = NO;
    self.glucoseLevelText.text = nil;
    [self hideKeyboard:nil];
}

- (void)editingChanged:(id)sender
{
    if ([self.glucoseLevelText.text length] != 0) {
        [self.parentViewController.navigationItem.rightBarButtonItem setEnabled:YES];
    } else {
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
    
    if ([cellId isEqualToString:@"GlucoseLevelCell"]) {
        [self.glucoseLevelText becomeFirstResponder];
    }
}

@end