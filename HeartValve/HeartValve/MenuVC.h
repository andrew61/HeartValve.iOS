//
//  SidebarVC.h
//  MUSCMedPlan
//
//  Created by Jonathan on 7/21/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuVC : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *updateCell;

@end