//
//  HomeVC.h
//  MyHealthApp
//
//  Created by Jonathan on 1/5/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeVC : UITableViewController

@property (weak, nonatomic) IBOutlet UIImageView *bloodPressureHKImage;
@property (weak, nonatomic) IBOutlet UIImageView *weightHKImage;
@property (weak, nonatomic) IBOutlet UIImageView *bloodGlucoseHKImage;
@property (weak, nonatomic) IBOutlet UILabel *versionLabel;
@property (weak, nonatomic) IBOutlet UITableViewCell *updateCell;

@end