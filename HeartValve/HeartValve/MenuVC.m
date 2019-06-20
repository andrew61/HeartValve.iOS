//
//  SidebarVC.m
//  MUSCMedPlan
//
//  Created by Jonathan on 7/21/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "MenuVC.h"
#import "UserManager.h"
#import "AppVersion.h"
#import "UIColor+Extensions.h"
#import "UIFont+Extensions.h"
#import "JNKeychain.h"
#import "AppDelegate.h"

@interface MenuVC ()

@end

@implementation MenuVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *version = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    self.versionLabel.text = [NSString stringWithFormat:@"%@", version];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)view;
    header.textLabel.font = [UIFont appFontBold:14];
    header.textLabel.textColor = [UIColor appBlueColor];
    header.contentView.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellId = cell.reuseIdentifier;
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    if ([cellId isEqualToString:@"LogOutCell"])
    {
        [JNKeychain deleteValueForKey:@"auth"];
        [JNKeychain deleteValueForKey:@"pin"];
        
        UIViewController *login = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginVC"];
        appDelegate.window.rootViewController = login;
        appDelegate.isAppLocked = YES;
    }
    else if ([cellId isEqualToString:@"UpdateCell"])
    {
        if (appDelegate.updateAvailable)
        {
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            [appDelegate updateApplication];
        }
    }
}

@end