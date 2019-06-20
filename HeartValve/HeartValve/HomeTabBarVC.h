//
//  HomeTabBarVC.h
//  MUSCMedPlan
//
//  Created by Jonathan on 7/21/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeTabBarVC : UITabBarController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *menuButton;
@property (strong, nonatomic) IBOutlet UIView *scrollingtabBarView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIButton *scheduleButton;
@property (weak, nonatomic) IBOutlet UIButton *medicationsButton;
@property (weak, nonatomic) IBOutlet UIButton *pillCapsButton;
@property (weak, nonatomic) IBOutlet UIButton *reportButton;
@property (weak, nonatomic) IBOutlet UIButton *measurementsButton;

- (IBAction)didTapTabBarButton:(UIButton *)sender;

@end