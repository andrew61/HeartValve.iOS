//
//  RegistrationVC.h
//  HeartValve
//
//  Created by Computer Science Department on 5/1/17.
//  Copyright © 2017 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XLFormViewController.h"


@interface RegistrationVC : XLFormViewController<UITableViewDelegate,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITextField *registrationEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *registrationPasswordTextField;
@property (weak, nonatomic) IBOutlet UITextField *registrationComfirmPasswordTextField;

@end
