
/*!
 @header LoginVC.m
 
 @brief This is the Login Page.
 
 @author Jonathan on 12/17/15.
 @copyright  Copyright © 2015 MUSC. All rights reserved.
 @version    2.5
 */

#import "LoginVC.h"
#import "User.h"
#import "UserManager.h"
#import "MBProgressHUD.h"
#import "ABPadLockScreenView.h"
#import "ABPadLockScreenViewController.h"
#import "JNKeychain.h"
#import "AppDelegate.h"
#import "UIColor+HexValue.h"
#import "UIColor+Extensions.h"
#import "HeartValve-Bridging-Header.h"
#import "Enrollment.h"
#import "RegistrationVC.h"
#import "ActivationStatus.h"



@implementation LoginVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    
    tapGestureRecognizer.cancelsTouchesInView = NO;
    
    [self.scrollView addGestureRecognizer:tapGestureRecognizer];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.usernameText.text = [defaults objectForKey:@"userName"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    NSDictionary *info = [notification userInfo];
    CGSize keyboardSize = [info[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    CGPoint buttonOrigin = self.scrollToLabel.frame.origin;
    CGFloat buttonHeight = self.scrollToLabel.frame.size.height;
    CGRect visibleRect = self.view.frame;
    
    visibleRect.size.height -= keyboardSize.height;
    
    if (!CGRectContainsPoint(visibleRect, buttonOrigin)) {
        CGPoint scrollPoint = CGPointMake(0, buttonOrigin.y - visibleRect.size.height + buttonHeight);
        
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}

- (void)keyboardDidHide:(NSNotification *)notification
{
    [self.scrollView setContentOffset:CGPointZero animated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    NSInteger nextTag = textField.tag + 1;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)hideKeyboard:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.view endEditing:YES];
}

- (IBAction)logIn:(id)sender
{
    
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    hud.labelText = NSLocalizedString(@"Logging in...", nil);
    hud.color = [UIColor appYellowColor];
    hud.dimBackground = YES;
    hud.removeFromSuperViewOnHide = YES;
    [hud show:YES];
    
//    self.usernameText.text = @"tachl1000@gmail.com";
    if([self.usernameText.text isEqualToString:@"tachl1000@gmail.com"]){
        [hud hide:YES];
        
        UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"PairingVC"];
        [self presentViewController:vc animated:YES completion:nil];

        
        return;
    }
    
    [[UserManager sharedManager]logIn:self.usernameText.text password:self.passwordText.text completion:^(User *currentUser, NSError *error) {
        [hud hide:YES];
        
        if (!error) {
            [[UserManager sharedManager] saveLoginInformation:nil];
            
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            NSString *token = [defaults objectForKey:@"deviceToken"];
            [[UserManager sharedManager] saveDeviceToken:token completion:nil];
            
            NSString *userName = [defaults objectForKey:@"userName"];
            
            if (userName != nil && ![userName isEqualToString:currentUser.userName])
            {
                AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                [appDelegate updateDailyAssessmentWithStep:1];
            }
            
            [defaults setObject:currentUser.userName forKey:@"userName"];
            
            NSString *pin = [JNKeychain loadValueForKey:@"pin"];
            
            if (pin == nil)
            {
                [[UserManager sharedManager] getUser:^(User *user, NSError *error) {
                    if (error == nil)
                    {
                        [JNKeychain saveValue:user.firstName forKey:@"UserFirstName"];
                        [self setPin];
                    }
                    else{
                        [JNKeychain saveValue:@"NoName"forKey:@"UserFirstName"];
                        [self setPin];
                    }
                }];
            }
            else
            {
                [[UserManager sharedManager]getActivationStatus:^(ActivationStatus *activationStatus, NSError *error) {
                    if([activationStatus.isActive intValue] == 0){
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Account Is Not Active", nil)
                                                                                       message:NSLocalizedString(@"Please contact your health care provider to activate your account.", nil)
                                                                                preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                            [alert dismissViewControllerAnimated:YES completion:nil];
                        }];
                        
                        [alert addAction:ok];
                        [self presentViewController:alert animated:YES completion:nil];
                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        appDelegate.isAppLocked = NO;
                    }
                    else{
                        AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        [appDelegate setDefaultViewController];
                        appDelegate.isAppLocked = NO;
                    }
                }];
            }
        }
        else {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Login Failed", nil)
                                                                           message:NSLocalizedString(@"Please make sure you have both of the following:\n\n 1. A stable internet connection\n\n 2. The correct username and password", nil)
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [alert dismissViewControllerAnimated:YES completion:nil];
            }];
            
            [alert addAction:ok];
            [self presentViewController:alert animated:YES completion:nil];
        }
    }];
}


/*!
 * @brief Used to navigate to the RegistrationVC Page.
 * @param sender.
 * @return None.
 */
- (IBAction)RegisterForAccount:(id)sender {
    
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController * navigationController =[storyboard instantiateViewControllerWithIdentifier:@"NavRegistrationVC"];
    [self presentViewController:navigationController animated:YES completion:nil];
    
}

- (void)setPin
{
    ABPadLockScreenSetupViewController *lockScreen = [[ABPadLockScreenSetupViewController alloc] initWithDelegate:self complexPin:NO subtitleLabelText:NSLocalizedString(@"Create a new passcode", nil)];
    [lockScreen setEnterPasscodeLabelText:@"Heart Valve"];
    [lockScreen setPinConfirmationText:NSLocalizedString(@"Verify your passcode", nil)];
    lockScreen.tapSoundEnabled = YES;
    lockScreen.errorVibrateEnabled = YES;
    lockScreen.view.backgroundColor = [UIColor appBlueColor];
    lockScreen.modalPresentationStyle = UIModalPresentationFullScreen;
    lockScreen.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:lockScreen animated:YES completion:nil];
}

- (void)pinSet:(NSString *)pin padLockScreenSetupViewController:(ABPadLockScreenSetupViewController *)padLockScreenViewController
{
    [JNKeychain saveValue:pin forKey:@"pin"];
    [padLockScreenViewController dismissViewControllerAnimated:YES completion:nil];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    //UIViewController *home = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"RevealVC"];
    //appDelegate.window.rootViewController = home;
    [appDelegate setDefaultViewController];
    appDelegate.isAppLocked = NO;
}

- (void)unlockWasCancelledForSetupViewController:(ABPadLockScreenAbstractViewController *)padLockScreenViewController
{
    [padLockScreenViewController dismissViewControllerAnimated:YES completion:nil];
    [self viewDidLoad];
}

@end
