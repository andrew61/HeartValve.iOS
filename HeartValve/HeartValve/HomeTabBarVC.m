//
//  HomeTabBarVC.m
//  MUSCMedPlan
//
//  Created by Jonathan on 7/21/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "HomeTabBarVC.h"
#import "SWRevealViewController.h"
#import "AppDelegate.h"
#import "UserManager.h"
#import "AppVersion.h"
#import "NotificationManager.h"
#import "UIButton+VerticalLayout.h"
#import "UIColor+Extensions.h"

@interface HomeTabBarVC ()

@end

@implementation HomeTabBarVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [[NSBundle mainBundle] loadNibNamed:@"ScrollingTabBarView" owner:self options:nil];
//    self.scrollingtabBarView.frame = CGRectMake(0, self.view.frame.size.height - 49, self.view.frame.size.width, 49);
//    self.scrollingtabBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    [self.view addSubview:self.scrollingtabBarView];
//    self.scrollView.contentSize = CGSizeMake(self.scheduleButton.frame.size.width + self.medicationsButton.frame.size.width + self.pillCapsButton.frame.size.width + self.reportButton.frame.size.width + self.measurementsButton.frame.size.width, 0);
//    self.scrollView.showsHorizontalScrollIndicator = NO;
//    self.scrollView.bounces = NO;
//    self.tabBar.barTintColor = [UIColor whiteColor];
//    self.tabBar.tintColor = [UIColor whiteColor];
//    self.tabBar.backgroundColor = [UIColor whiteColor];
//    
//    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }
//                                             forState:UIControlStateNormal];
//    [[UITabBarItem appearance] setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor whiteColor] }
//                                             forState:UIControlStateSelected];
//    [[UITabBar appearance] setBackgroundImage:[UIImage new]];
//    [[UITabBar appearance] setShadowImage:[UIImage new]];
//    
//    [self.scheduleButton setImage:[[UIImage imageNamed:@"schedule"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
//    [self.medicationsButton setImage:[[UIImage imageNamed:@"pill"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
//    [self.pillCapsButton setImage:[[UIImage imageNamed:@"pill"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
//    [self.reportButton setImage:[[UIImage imageNamed:@"report"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
//    [self.measurementsButton setImage:[[UIImage imageNamed:@"measurements"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
//    
//    [self.scheduleButton centerVertically];
//    [self.medicationsButton centerVertically];
//    [self.pillCapsButton centerVertically];
//    [self.reportButton centerVertically];
//    [self.measurementsButton centerVertically];
//    
//    self.scheduleButton.tintColor = [UIColor whiteColor];
//    self.medicationsButton.tintColor = [UIColor lightGrayColor];
//    self.pillCapsButton.tintColor = [UIColor lightGrayColor];
//    self.reportButton.tintColor = [UIColor lightGrayColor];
//    self.measurementsButton.tintColor = [UIColor lightGrayColor];
    
    if (self.revealViewController)
    {
        [self.menuButton setTarget:self.revealViewController];
        [self.menuButton setAction:@selector(revealToggle:)];
    }
    
    //[self checkApplicationVersion];
    //[self processRemoteNotifications];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.locationManager stopUpdatingLocation];
    [appDelegate transmitLocalStorage];
    //[appDelegate processMedicationActivity];
    
    self.tabBar.hidden = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.scrollingtabBarView.frame = CGRectMake(0, self.view.frame.size.height-49, self.view.frame.size.width, 49);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)checkApplicationVersion
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if (appDelegate.updateAvailable)
    {
        NSString *name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Update Available", nil) message:[NSString stringWithFormat:NSLocalizedString(@"A new version of %@ is available.  Would you like to update now?", nil), name] preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *update = [UIAlertAction actionWithTitle:NSLocalizedString(@"Update", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [appDelegate updateApplication];
        }];
        
        [alert addAction:update];
        [self.navigationController presentViewController:alert animated:YES completion:nil];
    }
}

- (void)processRemoteNotifications
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    for (NSDictionary *userInfo in appDelegate.remoteNotifications)
    {
        [[NotificationManager sharedManager] processRemoteNotification:userInfo];
    }
    [appDelegate.remoteNotifications removeAllObjects];
}

- (IBAction)didTapTabBarButton:(UIButton *)sender
{
    [self unselectTabs];
    
    switch (sender.tag) {
        case 0:
            [self.scheduleButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.scheduleButton.tintColor = [UIColor whiteColor];
            break;
            
        case 1:
            [self.medicationsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.medicationsButton.tintColor = [UIColor whiteColor];
            break;
            
        case 2:
            [self.pillCapsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.pillCapsButton.tintColor = [UIColor whiteColor];
            break;
            
        case 3:
            [self.reportButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.reportButton.tintColor = [UIColor whiteColor];
            break;
            
        case 4:
            [self.measurementsButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            self.measurementsButton.tintColor = [UIColor whiteColor];
            break;
            
        default:
            break;
    }
    
    self.selectedIndex = sender.tag;
}

- (void)unselectTabs
{
    [self.scheduleButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.medicationsButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.pillCapsButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.reportButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [self.measurementsButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    
    self.scheduleButton.tintColor = [UIColor lightGrayColor];
    self.medicationsButton.tintColor = [UIColor lightGrayColor];
    self.pillCapsButton.tintColor = [UIColor lightGrayColor];
    self.reportButton.tintColor = [UIColor lightGrayColor];
    self.measurementsButton.tintColor = [UIColor lightGrayColor];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        self.scrollingtabBarView.frame = CGRectMake(0, self.view.frame.size.height-49, self.view.frame.size.width, 49);
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    }];
}

@end
