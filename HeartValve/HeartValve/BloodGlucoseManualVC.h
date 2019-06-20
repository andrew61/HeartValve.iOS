//
//  BloodGlucoseManualVC.h
//  MyHealthApp
//
//  Created by Jonathan on 1/15/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BloodGlucoseManualVC : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *glucoseLevelText;

- (IBAction)saveBloodGlucose:(id)sender;
- (IBAction)editingChanged:(id)sender;

@end