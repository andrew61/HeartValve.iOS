//
//  MeasurementsVC.h
//  MUSCMedPlan
//
//  Created by Jonathan on 7/25/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeasurementsVC : UITableViewController<UITableViewDelegate,UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIImageView *bloodPressureHKImage;
@property (weak, nonatomic) IBOutlet UIImageView *weightHKImage;
@property (weak, nonatomic) IBOutlet UIImageView *bloodGlucoseHKImage;
@property (weak, nonatomic) IBOutlet UIImageView *oxygenSaturationHKImage;

@end
