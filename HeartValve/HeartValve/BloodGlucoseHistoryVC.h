//
//  BloodGlucoseHistoryVC.h
//  MyHealthApp
//
//  Created by Jonathan on 2/29/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BloodGlucoseHistoryVC : UIViewController

@property (weak, nonatomic) IBOutlet UIView *chartView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end