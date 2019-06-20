//
//  BloodPressureManualVC.h
//  MyHealthApp
//
//  Created by Jonathan on 1/14/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BloodPressureManualVC : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *systolicText;
@property (weak, nonatomic) IBOutlet UITextField *diastolicText;
@property (weak, nonatomic) IBOutlet UITextField *mapText;
@property (weak, nonatomic) IBOutlet UITextField *pulseText;

- (IBAction)saveBloodPressure:(id)sender;
- (IBAction)editingChanged:(id)sender;

@end