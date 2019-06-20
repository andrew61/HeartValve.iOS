//
//  WeightManualVC.h
//  MyHealthApp
//
//  Created by Jonathan on 1/14/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeightManualVC : UITableViewController

@property (weak, nonatomic) IBOutlet UITextField *weightText;

- (IBAction)saveWeight:(id)sender;
- (IBAction)editingChanged:(id)sender;

@end