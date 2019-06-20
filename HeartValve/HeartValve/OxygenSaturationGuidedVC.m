//
//  OxygenSaturationGuidedVC.m
//  HeartValve
//
//  Created by Jonathan on 11/2/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#define SDKClientID @"6a76ee9e601540f88fd5d12dace64d3e"
#define SDKClientSecret @"479eb06026b448ba84299bc61fa3f110"
#define SDKUserID @"tindalljon@hotmail.com"

#import "OxygenSaturationGuidedVC.h"
#import "POHeader.h"
#import "ScanDeviceController.h"
#import "OxygenSaturation.h"
#import "Utility.h"
#import "UserManager.h"
#import "MBProgressHUD.h"
#import "HealthKitManager.h"
#import "DbManager.h"
#import "AudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "UIColor+Extensions.h"
#import "AppDelegate.h"
#import "User.h"

@interface OxygenSaturationGuidedVC ()
{
    NSMutableArray *measurements;
    AVSpeechSynthesizer *synthesizer;
    NSString *audio;
    //    NSTimer *skipTimer;
    //    NSTimer *submitTimer;
    User *currentUser;
    int scanningCount;
}

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *timerStartDate;

@end

@implementation OxygenSaturationGuidedVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    scanningCount = 0;
    [self showDisconnectedView];
    self.spO2InProgress = NO;
    [[self.continueButton layer] setBorderWidth:1.0f];
    [[self.continueButton layer] setBorderColor:[UIColor appBlueColor].CGColor];
    [self.continueButton setBackgroundImage:[Utility imageWithColor:[UIColor appYellowColor]] forState:UIControlStateHighlighted];
    self.continueButton.hidden = YES;
    measurements = [NSMutableArray new];
    synthesizer = [AVSpeechSynthesizer new];
    self.BatteryInfo.hidden = YES;
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate updateDailyAssessmentWithStep:5];
    
    //show submit button in 40 seconds
    [self performSelector:@selector(ShowSubmitButton) withObject:nil afterDelay:35.0];
    
    //    skipTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(showSkip) userInfo:nil repeats:NO];
    //    submitTimer = [NSTimer scheduledTimerWithTimeInterval:45.0 target:self selector:@selector(showSkip) userInfo:nil repeats:NO];
    
    [[UserManager sharedManager]getUser:^(User *user, NSError *error) {
        if(error == nil){
            currentUser = user;
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceDidConnect:) name:PO3ConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceDidDisconnect:) name:PO3DisConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceDiscovered:) name:PO3Discover object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceDidFailToConnect:) name:PO3ConnectFailed object:nil];
    
    [self scan];
    
    audio = @"Place the pulse oximeter on any finger.  Rest your arms and hands comfortably.  Please hold still and do not move or talk.  Press the white button on the pulse oximeter firmly to turn on the display.";
    [AudioPlayer speak:audio withSynthesizer:synthesizer];
    
    
    //    if(skipTimer == nil){
    //        skipTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(showSkip) userInfo:nil repeats:NO];
    //    }
    //    if(submitTimer == nil){
    //        submitTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(showSkip) userInfo:nil repeats:NO];
    //    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    PO3 *po3 = [self getPO3];
    
    if (po3 != nil)
    {
        [po3 commandEndPO3CurrentConnect:nil DisposeErrorBlock:nil];
    }
    
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    //    if(skipTimer != nil){
    //        [skipTimer invalidate];
    //        skipTimer = nil;
    //    }
    //    if(submitTimer != nil){
    //        [submitTimer invalidate];
    //        submitTimer = nil;
    //    }
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (void)scan
{
    PO3 *po3 = [self getPO3];
    
    if (po3 != nil)
    {
        [self showConnectedView];
        
        HealthUser *user = [HealthUser new];
        
        user.clientID = SDKClientID;
        user.clientSecret = SDKClientSecret;
        user.userID = SDKUserID;
        
        [measurements removeAllObjects];
        
        [po3 commandCreatePO3User:user Authentication:nil DisposeResultBlock:^(BOOL finishSynchronous) {
            [po3 commandStartPO3MeasureData:^(BOOL startData) {
                self.spO2InProgress = YES;
            } Measure:^(NSDictionary *measureDataDic) {
                [self showMeasurementView];
                //                self.topHelpLabel.text = @"Please hold still and do not move or talk";
                
                OxygenSaturation *measurement = [OxygenSaturation new];
                measurement.spO2 = [NSNumber numberWithDouble:[measureDataDic[@"spo2"] doubleValue]];
                measurement.heartRate = [NSNumber numberWithInt:[measureDataDic[@"bpm"] intValue]];
                [measurements addObject:measurement];
                
                self.spO2Label.text = [NSString stringWithFormat:@"%d%@", measurement.spO2.intValue, @"%"];
                self.pulseLabel.text = [NSString stringWithFormat:@"%d", measurement.heartRate.intValue];
                
                if (self.spO2InProgress && self.timer == nil)
                {
                    self.secondsRemaining = 10;
                    self.timerStartDate = [NSDate date];
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkSessionDidTimeout) userInfo:nil repeats:YES];
                }
            } FinishPO3MeasureData:^(BOOL finishData) {
                if (self.timer != nil)
                {
                    [self.timer invalidate];
                }
                
                self.timer = nil;
                self.spO2InProgress = NO;
                [self saveOxygenSaturation];
            } DisposeErrorBlock:^(PO3ErrorID errorID) {
                
                switch (errorID) {
                    case PO3AccessError:
                        // Flash (Data) Access Error
                        break;
                    case PO3HardwareError:
                        // Irregular Hardware Error
                        break;
                    case PO3PRbpmtestError:
                        // The SpO2 or pulse rate test result is beyond the measurement range of the system
                        break;
                    case PO3UnknownError:
                        //Unknown Interference Detected
                        break;
                    case PO3SendCommandFaild:
                        // Send failed
                        break;
                    case PO3DeviceDisConect:
                        // Device is disconnected
                        break;
                    case PO3DataZero:
                        // No data
                        break;
                    case PO3UserInvalidate:
                        // User authentication fails
                        break;
                        
                    default:
                        break;
                }
                self.spO2InProgress = NO;
                
            }
             ];
        } DisposeErrorBlock:^(PO3ErrorID errorID) {
            
            switch (errorID) {
                case PO3AccessError:
                    // Flash (Data) Access Error
                    break;
                case PO3HardwareError:
                    // Irregular Hardware Error
                    break;
                case PO3UnknownError:
                    //Unknown Interference Detected
                    break;
                case PO3SendCommandFaild:
                    // Send failed
                    break;
                case PO3DeviceDisConect:
                    // Device is disconnected
                    break;
                case PO3UserInvalidate:
                    // User authentication fails
                    break;
                default:
                    break;
            }
        }];
        [po3 commandQueryBatteryInfo:^(BOOL resetSuc) {
            if (resetSuc){
                NSLog(@"Got battery percentage.");
            }
        } DisposeErrorBlock:^(PO3ErrorID errorID) {
            //Something.
            NSLog(@"Testing.");
            switch (errorID) {
                case PO3AccessError:
                    NSLog(@"Flash (Data) Access Error.");
                    
                    break;
                case PO3HardwareError:
                    // Irregular Hardware Error
                    NSLog(@"Irregular Hardware Error.");
                    
                    break;
                case PO3PRbpmtestError:
                    // The SpO2 or pulse rate test result is beyond the measurement range of the system
                    NSLog(@"The SpO2 or pulse rate test result is beyond the measurement range of the system.");
                    
                    break;
                case PO3UnknownError:
                    //Unknown Interference Detected
                    NSLog(@"Unknown Interference Detected.");
                    
                    break;
                case PO3SendCommandFaild:
                    // Send failed
                    NSLog(@"Send failed.");
                    
                    break;
                case PO3DeviceDisConect:
                    // Device is disconnected
                    NSLog(@"Device is disconnected");
                    
                    break;
                case PO3DataZero:
                    // No data
                    NSLog(@"No data");
                    
                    break;
                case PO3UserInvalidate:
                    // User authentication fails
                    NSLog(@"User authentication fails");
                    
                    break;
                    
                default:
                    break;
            }
            
        } DisposeBattery:^(NSNumber * battery) {
            NSLog(@"This is the current device battery percentage %d%%",battery.intValue);
            const int batteryPercentage = [battery intValue];
            
            if(batteryPercentage >= 80){
                
                self.BatteryInfo.text = [NSString stringWithFormat:@"Pulse Oximeter Battery Percentage: %d%%.",battery.intValue];
                self.BatteryInfo.textColor = UIColor.greenColor;
            }
            else if(batteryPercentage < 80 && batteryPercentage > 50){
                self.BatteryInfo.text = [NSString stringWithFormat:@"Pulse Oximeter Battery Percentage: %d%%. Consider charging your device.",battery.intValue];
                self.BatteryInfo.textColor = UIColor.orangeColor;
            }
            else if(batteryPercentage <= 50){
                self.BatteryInfo.hidden = NO;
                self.BatteryInfo.text = [NSString stringWithFormat:@"Pulse Oximeter Battery Percentage: %d%%. Device needs to be charged!",battery.intValue];
                self.BatteryInfo.textColor = UIColor.redColor;
            }
            else{
                self.BatteryInfo.hidden = YES;
            }
        }];
        
    }
    else
    {
        [[ScanDeviceController commandGetInstance] commandScanDeviceType:HealthDeviceType_PO3];
        [self showDisconnectedView];
    }
}

- (void)checkSessionDidTimeout
{
    if (self.timerStartDate != nil)
    {
        NSDate *date = [NSDate date];
        NSTimeInterval interval = [date timeIntervalSinceDate:self.timerStartDate];
        
        if (interval > self.secondsRemaining - 1)
        {
            [self.timer invalidate];
            self.timerStartDate = nil;
            self.timer = nil;
            self.spO2InProgress = NO;
            self.topHelpLabel.text = @"Please remove the pulse oximeter from your finger.";
            audio = @"Please remove the pulse oximeter from your finger.";
            [AudioPlayer speak:audio withSynthesizer:synthesizer];
            //            self.bottomHelpLabel.hidden =YES;
        }
        else
        {
            self.topHelpLabel.hidden = NO;
            //            self.bottomHelpLabel.hidden =YES;
        }
    }
}

- (void)deviceDidConnect:(NSNotification *)info
{
    [self scan];
}

- (void)deviceDidDisconnect:(NSNotification *)info
{
    [self showDisconnectedView];
    [[ScanDeviceController commandGetInstance] commandScanDeviceType:HealthDeviceType_PO3];
}

- (void)deviceDiscovered:(NSNotification *)info
{
    scanningCount +=1;
    NSLog(@"Scanning count: %d",scanningCount);
    [[ScanDeviceController commandGetInstance] commandStopScanDeviceType:HealthDeviceType_PO3];
    
    NSString *ID = [[info userInfo] objectForKey:@"ID"];
    NSString *serialNumber = [[info userInfo] objectForKey:@"SerialNumber"];
    NSLog(@"serialNumber TRUE: %@",[[info userInfo] objectForKey:@"SerialNumber"]);
    NSLog(@"Device ID TRUE: %@",ID);
    
    if (serialNumber != nil)
    {
        //Cancels performSelector requests.
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
        [[ConnectDeviceController commandGetInstance] commandContectDeviceWithDeviceType:HealthDeviceType_PO3 andSerialNub:serialNumber];
    }
    else
    {
        [[ConnectDeviceController commandGetInstance] commandContectDeviceWithDeviceType:HealthDeviceType_PO3 andSerialNub:ID];
        
    }
}

- (void)deviceDidFailToConnect:(NSNotification *)info
{
    [self scan];
    //    self.continueButton.hidden = NO;
}

- (PO3 *)getPO3
{
    NSArray *po3Array = [[PO3Controller shareIHPO3Controller] getAllCurrentPO3Instace];
    
    if (po3Array.count > 0)
    {
        return [po3Array objectAtIndex:0];
    }
    
    return nil;
}

- (void)showConnectedView
{
    self.statusLabel.text = @"The device is connected";
    self.topHelpLabel.text = @"Place the pulse oximeter on any finger.  Rest your arms and hands comfortably.  Press the button firmly to start a measurement.";
    //    self.bottomHelpLabel.text = nil;
    self.statusLabel.hidden = NO;
    self.topHelpLabel.hidden = NO;
    //    self.bottomHelpLabel.hidden = NO;
    self.connectedImageView.hidden = NO;
    self.connectedImageView.image =  [UIImage animatedImageNamed:@"oximeter-" duration:1.0f];
    self.spO2Label.hidden = YES;
    self.pulseLabel.hidden = YES;
        self.spO2View.hidden = YES;
    //    self.pulseView.hidden = YES;
}

- (void)showDisconnectedView
{
    self.statusLabel.text = @"The device is not connected";
    self.topHelpLabel.text = @"Place the pulse oximeter on any finger.  Rest your arms and hands comfortably.  Press the button to start a measurement.";
    //    self.bottomHelpLabel.text = @"Please make sure Bluetooth is turned on.";
    //    self.bottomHelpLabel.text = nil;
    self.statusLabel.hidden = NO;
    self.topHelpLabel.hidden = NO;
    //self.bottomHelpLabel.hidden = YES;
    self.connectedImageView.hidden = YES;
    self.spO2Label.hidden = YES;
    self.pulseLabel.hidden = YES;
    //    self.spO2View.hidden = YES;
    //    self.pulseView.hidden = YES;
}

- (void)showMeasurementView
{
    //    if(skipTimer != nil){
    //        [skipTimer invalidate];
    //        skipTimer = nil;
    //    }
    //self.statusLabel.hidden = YES;
    //self.topHelpLabel.hidden = YES;
    //self.bottomHelpLabel.hidden = YES;
    self.connectedImageView.hidden = YES;
    self.spO2View.hidden = NO;
    self.spO2Label.hidden = NO;
    //    self.pulseView.hidden = NO;
}

- (void)showSkip
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.continueButton.hidden = NO;
    });
}

- (void)saveOxygenSaturation
{
    MBProgressHUD * hud = [Utility getHUDAddedTo:self.view withText:@"Loading..."];
    
    [hud show:YES];
    
    [self HideViews];
    
    if (measurements.count > 0)
    {
        //        if(submitTimer != nil){
        //            [submitTimer invalidate];
        //            submitTimer = nil;
        //        }
        OxygenSaturation *measurement = [measurements lastObject];
        
        //save to health kit
        [[HealthKitManager sharedManager] saveOxygenSaturation:measurement];
        
        //save to Tachl
        [[UserManager sharedManager] saveOxygenSaturation:measurement completion:^(NSError *error) {
            
            // If error occurs save measurement into local DB.
            if (error != nil)
            {
                if ([[DbManager sharedManager] insertOxygenSaturation:measurement])
                {
                    
                    [self performSelector:@selector(NextAssessment) withObject:nil afterDelay:2.0];
                    [hud hide:YES];
                    
                }
                
                else
                {
                    [hud hide:YES];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Save Failed!", nil)
                                                                                   message:NSLocalizedString(@"Please make sure you have a stable internet connection.", nil)
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        [alert dismissViewControllerAnimated:YES completion:^{
                            [self performSelector:@selector(NextAssessment) withObject:nil afterDelay:1.0];
                        }];
                    }];
                    
                    [alert addAction:ok];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
            
            else{
                
                [self performSelector:@selector(NextAssessment) withObject:nil afterDelay:2.0];
                [hud hide:YES];
            }
        }];
    }
    else
    {
        [hud hide:YES];
        [self scan];
    }
}
- (void)NextAssessment
{
        UIViewController *vc = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"CompletionVC"];
        [self showViewController:vc sender:self];
}
- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self checkSessionDidTimeout];
}

- (IBAction)replayAudio:(id)sender
{
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    synthesizer = [AVSpeechSynthesizer new];
    [AudioPlayer speak:audio withSynthesizer:synthesizer];
}

-(BOOL) textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    const char *c = [string cStringUsingEncoding:NSUTF8StringEncoding];
    int backspaceChar = strcmp(c, "\\b");
    
    bool isBackspace = NO;
    if(backspaceChar == -92){
        isBackspace = YES;
    }
    
    if(textField.text != nil){
        if(textField.text.length == 2){
            if(([textField.text intValue] == 10 && [string intValue] == 0) || isBackspace){
                return YES;
            }else{
                return NO;
            }
        }else{
            if(textField.text.length == 3){
                if(isBackspace){
                    return YES;
                }else{
                    return NO;
                }
            }
        }
    }
    return YES;
}

-(void)HideViews{
    //    self.bottomHelpLabel.hidden = YES;
    self.topHelpLabel.hidden = YES;
    self.statusLabel.hidden = YES;
    self.continueButton.hidden = YES;
    self.BatteryInfo.hidden = YES;
    self.replayButton.hidden = YES;
    self.connectedImageView.hidden = YES;
}

- (void)ShowSubmitButton
{
    [AudioPlayer speak:@"Having trouble? Push the blue submit button to manually submit your oxygen saturation." withSynthesizer:synthesizer];
    self.statusLabel.text = @"Push the submit button.";
    [self showSkip];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    //Kills communication with the pulse oximeter.
    PO3 *po3 = [self getPO3];
    
    if (po3 != nil)
    {
        //        causing crashes
        //        [po3 commandEndPO3CurrentConnect:nil DisposeErrorBlock:nil];
    }
}

- (IBAction)SubmitButtonClicked:(id)sender {
    UIAlertController * alertController = [UIAlertController alertControllerWithTitle: @"Enter Oxygen Saturation "
                                                                              message: @""
                                                                       preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"";
        textField.font =  [textField.font fontWithSize:70];
        textField.textAlignment = NSTextAlignmentCenter;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        textField.delegate=self;
        
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSArray * textfields = alertController.textFields;
        UITextField * inputValue = textfields[0];
        NSNumber * oxSaturation = [NSNumber numberWithInt:([inputValue.text isEqualToString:@""])? 0 :inputValue.text.intValue];
        OxygenSaturation *measurement = [OxygenSaturation new];
        measurement.spO2 = [NSNumber numberWithDouble:[oxSaturation doubleValue]];
        measurement.heartRate = 0;
        measurement.readingDate = [NSDate new];
        
        [measurements addObject:measurement];
        
        [self saveOxygenSaturation];
        
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"Skip" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self performSelector:@selector(NextAssessment) withObject:nil afterDelay:2.0];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}
@end
