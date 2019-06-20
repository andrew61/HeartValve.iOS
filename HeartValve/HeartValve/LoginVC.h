//
//  LoginVC.h
//  MyHealthApp
//
//  Created by Jonathan on 12/17/15.
//  Copyright © 2015 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ABPadLockScreenSetupViewController.h"

@interface LoginVC : UIViewController<UITextFieldDelegate, ABPadLockScreenSetupViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *logInButton;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *usernameText;
@property (weak, nonatomic) IBOutlet UITextField *passwordText;
@property (weak, nonatomic) IBOutlet UILabel *scrollToLabel;

- (IBAction)logIn:(id)sender;
- (IBAction)RegisterForAccount:(id)sender;

@end
