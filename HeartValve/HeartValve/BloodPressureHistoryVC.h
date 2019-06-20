//
//  BloodPressureHistoryVC.h
//  MyHealthApp
//
//  Created by Jonathan on 2/28/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BloodPressureHistoryVC : UIViewController

@property (weak, nonatomic) IBOutlet UIView *chartView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end