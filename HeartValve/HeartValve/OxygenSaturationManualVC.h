//
//  OxygenSaturationManualVC.h
//  HeartValve
//
//  Created by Jonathan on 10/11/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OxygenSaturationManualVC : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *spO2Text;
@property (weak, nonatomic) IBOutlet UITextField *heartRateText;

- (IBAction)saveOxygenSaturation:(id)sender;
- (IBAction)editingChanged:(id)sender;

@end
