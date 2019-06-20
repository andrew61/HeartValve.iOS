
/*!
 @header RegistrationVC.m
 
 @brief This is the Registration Page.
 
 @author Jamseon Burroughs on 12/17/15.
 @copyright  Copyright © 2017 MUSC. All rights reserved.
 @version    2.5
 */


#import "RegistrationVC.h"
#import "MBProgressHUD.h"
#import "UIColor+HexValue.h"
#import "UIColor+Extensions.h"
#import "UserManager.h"
#import "Utility.h"
#import "UIFont+Extensions.h"
#import "UIColor+Extensions.h"
#import "LoginVC.h"
#import "XLForm.h"

@implementation RegistrationVC

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self){
        [self initializeForm];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self){
        [self initializeForm];
    }
    return self;
}

-(void)viewDidLoad{
    
    [super viewDidLoad];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:self action:@selector(GoToBackLoginPage)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSIndexPath *selected = [self.tableView indexPathForSelectedRow];
    if (selected){
        // Trigger a cell refresh
        XLFormRowDescriptor * rowDescriptor = [self.form formRowAtIndex:selected];
        [self updateFormRow:rowDescriptor];
        [self.tableView selectRowAtIndexPath:selected animated:NO scrollPosition:UITableViewScrollPositionNone];
        [self.tableView deselectRowAtIndexPath:selected animated:YES];
    }

    
}

- (void)initializeForm {
    
    static NSString *const XLFormRowDescriptorTypeName = @"name";
    static NSString *const XLFormRowDescriptorTypeEmail = @"email";
//    static NSString *const XLFormRowDescriptorTypePassword = @"password";
//    static NSString *const XLFormRowDescriptorTypePhone = @"phone";

    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    form = [XLFormDescriptor formDescriptorWithTitle:@"User Registration"];
    
    // First section
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // First Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"firstName" rowType:XLFormRowDescriptorTypeName];
    [row.cellConfigAtConfigure setObject:@"Enter Here" forKey:@"textField.placeholder"];
    row.title =@"First Name: ";
    [section addFormRow:row];
    
    // Last Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"lastName" rowType:XLFormRowDescriptorTypeName];
    [row.cellConfigAtConfigure setObject:@"Enter Here" forKey:@"textField.placeholder"];
    row.title =@"Last Name: ";
    [section addFormRow:row];
    
    // First Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"mrn" rowType:XLFormRowDescriptorTypeInteger];
    [row.cellConfigAtConfigure setObject:@"Enter Here" forKey:@"textField.placeholder"];
    row.title =@"MRN: ";
    [section addFormRow:row];
    
    
    
    
//    // Phone Number
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"phoneNumber" rowType:XLFormRowDescriptorTypePhone];
//    [row.cellConfigAtConfigure setObject:@"Enter Here" forKey:@"textField.placeholder"];
//    row.title =@"Phone Number: ";
//    [section addFormRow:row];
    
    
    // Email
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"email" rowType:XLFormRowDescriptorTypeEmail];
    [row.cellConfigAtConfigure setObject:@"Enter Here" forKey:@"textField.placeholder"];
    row.title =@"Email: ";
    [section addFormRow:row];
    
    
//    // Password
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"password" rowType:XLFormRowDescriptorTypePassword];
//    [row.cellConfigAtConfigure setObject:@"Enter Here" forKey:@"textField.placeholder"];
//    row.title =@"Password: ";
//    [section addFormRow:row];
//    
//    
//    // Password Confirmed
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"passwordConfirmed" rowType:XLFormRowDescriptorTypePassword];
//    [row.cellConfigAtConfigure setObject:@"Enter Here" forKey:@"textField.placeholder"];
//    row.title =@"Password Confirmed: ";
//    [section addFormRow:row];
    
    // Second section
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
//    // Third section
//    section = [XLFormSectionDescriptor formSection];
//    [form addFormSection:section];
    
    
    ///Registration row
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"saveButton" rowType:XLFormRowDescriptorTypeName];
    [row.cellConfigAtConfigure setObject:@(NSTextAlignmentCenter) forKey:@"textField.textAlignment"];
    
    [row.cellConfig setObject:[UIColor appYellowColor] forKey:@"textField.textColor"];
    [row.cellConfig setObject:[UIFont appFont:28] forKey:@"textField.font"];
    row.disabled = @YES;
    row.noValueDisplayText = @"Register";

    [section addFormRow:row];
//    // Enrollment Date
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"enrollmentDate" rowType:XLFormRowDescriptorTypeDateInline];
//    [row.cellConfigAtConfigure setObject:@"Enrollment Date" forKey:@"textField.placeholder"];
//    [section addFormRow:row];
//    
//    // Systolic Min Threshold
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"systolicMinThreshold" rowType:XLFormRowDescriptorTypeNumber];
//    [row.cellConfigAtConfigure setObject:@"Systolic Min Threshold" forKey:@"textField.placeholder"];
//    [section addFormRow:row];
//    
//    // Systolic Max Threshold
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"systolicMaxThreshold" rowType:XLFormRowDescriptorTypeNumber];
//    [row.cellConfigAtConfigure setObject:@"Systolic Max Threshold" forKey:@"textField.placeholder"];
//    [section addFormRow:row];
//    
//    
//    // Diastolic Min Threshold
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"diastolicMinThreshold" rowType:XLFormRowDescriptorTypeNumber];
//    [row.cellConfigAtConfigure setObject:@"Diastolic Min Threshold" forKey:@"textField.placeholder"];
//    [section addFormRow:row];
//    
//    // Diastolic Max Threshold
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"diastolicMaxThreshold" rowType:XLFormRowDescriptorTypeNumber];
//    [row.cellConfigAtConfigure setObject:@"Diastolic Max Threshold" forKey:@"textField.placeholder"];
//    [section addFormRow:row];
//    
//    // Heart Rate Min Threshold
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"heartRateMinThreshold" rowType:XLFormRowDescriptorTypeNumber];
//    [row.cellConfigAtConfigure setObject:@"Heart Rate Min Threshold" forKey:@"textField.placeholder"];
//    [section addFormRow:row];
//    
//    // Heart Rate Max Threshold
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"heartRateMaxThreshold" rowType:XLFormRowDescriptorTypeNumber];
//    [row.cellConfigAtConfigure setObject:@"Heart Rate Min Threshold" forKey:@"textField.placeholder"];
//    [section addFormRow:row];
//    
//    // Sp02 Min Threshold
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"sp02RateMinThreshold" rowType:XLFormRowDescriptorTypeNumber];
//    [row.cellConfigAtConfigure setObject:@"Sp02 Rate Min Threshold" forKey:@"textField.placeholder"];
//    [section addFormRow:row];
//    
//    // Sp02 Rate Max Threshold
//    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"sp02RateMaxThreshold" rowType:XLFormRowDescriptorTypeNumber];
//    [row.cellConfigAtConfigure setObject:@"Sp02 Rate Max Threshold" forKey:@"textField.placeholder"];
//    [section addFormRow:row];

    self.form = form;
}



- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

//Change the Height of the Cell [Default is 44]:
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {

            return 60;
        }
    }
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XLFormRowDescriptor * rowDescriptor = [self.form formRowAtIndex:indexPath];

    return [rowDescriptor cellForFormController:self];
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    XLFormRowDescriptor * row = [self.form formRowAtIndex:indexPath];
    

    if (row.isDisabled) {
        
        if([self checkFields]){
            
            [self registerUser];
        }
        
        return;
    }
    
    [self didSelectFormRow:row];
}

/*!
 * @brief Used to register the user.
 * @param None.
 * @return None/Void.
 */
- (void)registerUser
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Enter Verification Code", nil)
                                                                   message:NSLocalizedString(@"Please allow your provider to enter the verification code.", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Verification Code";
        textField.secureTextEntry = YES;
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = NSLocalizedString(@"Verifing Information...", nil);
        hud.color = [UIColor appYellowColor];
        hud.dimBackground = YES;
        hud.removeFromSuperViewOnHide = YES;
        [hud show:YES];
        UITextField *verificationCode = alert.textFields.firstObject;
//        NSString *phoneNumber = [self.form formRowWithTag:@"phoneNumber"].value ;
          NSString *userID = [self.form formRowWithTag:@"firstName"].value ;
        NSString *mrn = [self.form formRowWithTag:@"mrn"].value;
        NSString *lastName = [self.form formRowWithTag:@"lastName"].value;

        
        [[UserManager sharedManager]registerUser:userID lastName:lastName phoneNumber:@"123-456-7890" email:[self.form formRowWithTag:@"email"].value password:@"Hv!1234" confirmedPassword:@"Hv!1234" verificationCode:verificationCode.text mrn:mrn completion:^(NSError* error) {
            [hud hide:YES];
            
            ///if Successfull
            if (!error)
            {
                
                [self presentViewController:[self registrationSuccess] animated:YES completion:nil];

                
            }
            else
            {
                [self presentViewController:[self invaildVerificationCode] animated:YES completion:nil];
                
            }
        }];
        
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

/*!
 * @brief Checks the text fields for empty fields, invalid email format, invalid password formats, and if the password matches.
 * @param None.
 * @return boolean.
 */
-(BOOL) checkFields{
    
    NSString *emailRegex = @"[A-Z0-9a-z]+([._%+-]{1}[A-Z0-9a-z]+)*@[A-Z0-9a-z]+([.-]{1}[A-Z0-9a-z]+)*(\\.[A-Za-z]{2,4}){0,1}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    
    ///Checks if fields are not  empty.
//    if([[self.form formRowWithTag:@"firstName"].value length] > 0 && [[self.form formRowWithTag:@"lastName"].value length] > 0 && [[self.form formRowWithTag:@"email"].value length] > 0 && [[self.form formRowWithTag:@"password"].value length] > 0 && [[self.form formRowWithTag:@"passwordConfirmed"].value length] > 0)
    
    ///Checks if fields are not  empty.
    if([[self.form formRowWithTag:@"firstName"].value length] > 0 && [[self.form formRowWithTag:@"email"].value length] > 0){
        
        ///Checks if email format is valid
        if([emailTest evaluateWithObject:[self.form formRowWithTag:@"email"].value]){
            
            return TRUE;

//            if([[self.form formRowWithTag:@"password"].value length] >= 6)
//            {
//                
//                NSString *stricterFilterString = @"^(?=.*[a-z])(?=.*[A-Z])(?=.*\\d)(?=.*[$@$!%*?&+~\\-\\_])[A-Za-z\\d$@$!%*?&+~\\-\\_]{6,}";
//                NSPredicate *passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", stricterFilterString];
//                
//                if([passwordTest evaluateWithObject:[self.form formRowWithTag:@"password"].value])
//                {
//                    if([[self.form formRowWithTag:@"password"].value isEqualToString:[self.form formRowWithTag:@"passwordConfirmed"].value]){
//                        return TRUE;
//                    }
//                    else{
//                        [self presentViewController:[self invaildMatch] animated:YES completion:nil];
//                    }
//                }
//                else
//                {
//                    [self presentViewController:[self invaildPassword] animated:YES completion:nil];
//                }
//                
//            }
//            else
//            {
//                [self presentViewController:[self invaildPassword2] animated:YES completion:nil];
//            }
        
        }
        
        else{
            [self presentViewController:[self invaildEmail] animated:YES completion:nil];
        }
    }
    else{
        [self presentViewController:[self emptyFields] animated:YES completion:nil];
    }
    
    
    return NO;
}

/*!
 * @brief Horizontally shakes the table cell.
 * @param None.
 * @return UITableViewCell.
 */
-(void)animateCell:(UITableViewCell *)cell
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position.x";
    animation.values =  @[ @0, @20, @-20, @10, @0];
    animation.keyTimes = @[@0, @(1 / 6.0), @(3 / 6.0), @(5 / 6.0), @1];
    animation.duration = 0.3;
    animation.repeatCount = 2;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animation.additive = YES;
    
    [cell.layer addAnimation:animation forKey:@"shake"];
}

/*!
 * @brief Displays an alert to the user when the verification code is invaild.
 * @param None.
 * @return UIAlertController object.
 */
-(UIAlertController*)invaildVerificationCode{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Registration Failed"
                                                                   message:@"Invaild Verification Code. Please try again." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {}];
    [alert addAction:defaultAction];
    return alert;
}

/*!
 * @brief Displays an alert to the user when the email field is not in email format.
 * @param None.
 * @return UIAlertController object.
 */
-(UIAlertController*)invaildEmail{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invaild Email Format"
                                                                   message:@"Please enter a vaild email. Ex. ****@gmail.com" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                            
                                                                [self.form formRowWithTag:@"email"].value = @"";
                                                                [self updateFormRow:[self.form formRowWithTag:@"email"]];
                                                                [self animateCell:[[self.form formRowWithTag:@"email"] cellForFormController:self]];
                                                            }];
    
    [alert addAction:defaultAction];
    return alert;
}

/*!
 * @brief Congrats you have successfully registered.
 * @param None.
 * @return UIAlertController object.
 */
-(UIAlertController*)registrationSuccess{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Congrats you have successfully registered."
                                                                   message:@"Please remember your entered email and password." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                
                                                                UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                LoginVC * controller = (LoginVC *)[storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
                                                                [self presentViewController:controller animated:YES completion:nil];
                                                            }];
    
    [alert addAction:defaultAction];
    return alert;
}

/*!
 * @brief Displays an alert to the user when the password field does not have at least one lower case letter, one upper case letter, one digit and one special character.
 * @param None.
 * @return UIAlertController object.
 */
-(UIAlertController*)invaildPassword{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invaild Password Format"
                                                                   message:@"Please ensure that you have at least one lower case letter, one upper case letter, one digit and one special character in your password." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                            
                                                                [self.form formRowWithTag:@"password"].value = @"";
                                                                [self.form formRowWithTag:@"passwordConfirmed"].value = @"";
                                                                [self updateFormRow:[self.form formRowWithTag:@"password"]];
                                                                [self updateFormRow:[self.form formRowWithTag:@"passwordConfirmed"]];
                                                                [self animateCell:[[self.form formRowWithTag:@"password"] cellForFormController:self]];
                                                                [self animateCell:[[self.form formRowWithTag:@"passwordConfirmed"] cellForFormController:self]];


                                                            }];
    
    [alert addAction:defaultAction];
    return alert;
}

/*!
 * @brief Displays an alert to the user when the password field is not at least 6 characters.
 * @param None.
 * @return UIAlertController object.
 */
-(UIAlertController*)invaildPassword2{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Invaild Password Format"
                                                                   message:@"Please enter a password that is at least 6 characters." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                
                                                                [self.form formRowWithTag:@"password"].value = @"";
                                                                [self.form formRowWithTag:@"passwordConfirmed"].value = @"";
                                                                [self updateFormRow:[self.form formRowWithTag:@"password"]];
                                                                [self updateFormRow:[self.form formRowWithTag:@"passwordConfirmed"]];
                                                                [self animateCell:[[self.form formRowWithTag:@"password"] cellForFormController:self]];
                                                                [self animateCell:[[self.form formRowWithTag:@"passwordConfirmed"] cellForFormController:self]];
                                                            }];
    
    [alert addAction:defaultAction];
    return alert;
}


/*!
 * @brief Displays an alert to the user when the password and passwordConfirmed fields does not match.
 * @param None.
 * @return UIAlertController object.
 */
-(UIAlertController*)invaildMatch{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Passwords Don't Match"
                                                                   message:@"Please make sure your passwords match." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                [self.form formRowWithTag:@"password"].value = @"";
                                                                [self.form formRowWithTag:@"passwordConfirmed"].value = @"";
                                                                [self updateFormRow:[self.form formRowWithTag:@"password"]];
                                                                [self updateFormRow:[self.form formRowWithTag:@"passwordConfirmed"]];

                                                            }];
    
    [alert addAction:defaultAction];
    return alert;
}

/*!
 * @brief Displays an alert to the user when all text fields are empty.
 * @param None.
 * @return UIAlertController object.
 */
-(UIAlertController*)emptyFields{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Empty Fields"
                                                                   message:@"All field are required." preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK"
                                                            style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {

                                                                [self animateCell:[[self.form formRowWithTag:@"firstName"] cellForFormController:self]];
                                                                [self animateCell:[[self.form formRowWithTag:@"email"] cellForFormController:self]];
//                                                                [self animateCell:[[self.form formRowWithTag:@"lastName"] cellForFormController:self]];
//                                                                [self animateCell:[[self.form formRowWithTag:@"phoneNumber"] cellForFormController:self]];
//                                                                [self animateCell:[[self.form formRowWithTag:@"password"] cellForFormController:self]];
//                                                                [self animateCell:[[self.form formRowWithTag:@"passwordConfirmed"] cellForFormController:self]];
                                                            }];
    
    [alert addAction:defaultAction];
    return alert;
}

/*!
 * @brief Used to navigate back to the login page after the user has successfully registered.
 * @param None.
 * @return None.
 */
-(void)GoToBackLoginPage{
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LoginVC * controller = (LoginVC *)[storyboard instantiateViewControllerWithIdentifier:@"LoginVC"];
    [self presentViewController:controller animated:YES completion:nil];
}

@end
