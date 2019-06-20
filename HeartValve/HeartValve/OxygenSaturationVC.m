//
//  OxygenSaturationVC.m
//  HeartValve
//
//  Created by Jonathan on 10/4/16.
//  Copyright © 2016 MUSC. All rights reserved.
//


#define SDKClientID @"6a76ee9e601540f88fd5d12dace64d3e"
#define SDKClientSecret @"479eb06026b448ba84299bc61fa3f110"
#define SDKUserID @"tindalljon@hotmail.com"
#import "OxygenSaturationVC.h"
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
#import <LocalAuthentication/LocalAuthentication.h>
#import "JNKeychain.h"

@interface OxygenSaturationVC ()
{
    NSMutableArray *measurements;
    AVSpeechSynthesizer *synthesizer;
}

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *timerStartDate;

@end

@implementation OxygenSaturationVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self showDisconnectedView];
    self.spO2InProgress = NO;
    self.falseToConnect = NO;
    measurements = [NSMutableArray new];
    synthesizer = [AVSpeechSynthesizer new];
    self.BatteryInfo.hidden = YES;
    self.skipButton.hidden = YES;

    
    //show submit button in 30 seconds
    [self performSelector:@selector(ShowSubmitButton) withObject:nil afterDelay:25.0];

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
    
    [AudioPlayer speak:@"Place the pulse oximeter on any finger.  Rest your arms and hands comfortably.  Please hold still and do not move or talk.  Press the white button on the pulse oximeter firmly to turn on the display." withSynthesizer:synthesizer];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    PO3 *po3 = [self getPO3];
    

    [po3 commandEndPO3CurrentConnect:nil DisposeErrorBlock:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(ShowSubmitButton) object: nil];

    
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
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
        
        //Cancels performSelector requests.
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
        [measurements removeAllObjects];
        
        [po3 commandCreatePO3User:user Authentication:nil DisposeResultBlock:^(BOOL finishSynchronous) {
            [po3 commandStartPO3MeasureData:^(BOOL startData) {
                self.spO2InProgress = YES;
            } Measure:^(NSDictionary *measureDataDic) {
                [self showMeasurementView];
                //self.topHelpLabel.text = @"Please hold still and do not move or talk";
                
                OxygenSaturation *measurement = [OxygenSaturation new];
                measurement.spO2 = [NSNumber numberWithDouble:[measureDataDic[@"spo2"] doubleValue]];
                measurement.heartRate = [NSNumber numberWithInt:[measureDataDic[@"bpm"] intValue]];
                [measurements addObject:measurement];
                
                self.spO2Label.text = [NSString stringWithFormat:@"%d", measurement.spO2.intValue];
                self.pulseLabel.text = [NSString stringWithFormat:@"%d", measurement.heartRate.intValue];
                
                if (self.spO2InProgress && self.timer == nil)
                {
                    self.secondsRemaining = 10;
                    self.timerStartDate = [NSDate date];
                    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkSessionDidTimeout) userInfo:nil repeats:YES];
//                    [AudioPlayer speak:@"Please wait one minute and remove the pulse oximeter from your finger." withSynthesizer:synthesizer];
                }
            } FinishPO3MeasureData:^(BOOL finishData) {
                if (self.timer != nil)
                {
                    [self.timer invalidate];
                }
                
                self.timer = nil;
                self.spO2InProgress = NO;
                [self authenticate];
            } DisposeErrorBlock:^(PO3ErrorID errorID) {
                
                self.falseToConnect = TRUE;

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
                [self scan];

            }
             ];
        } DisposeErrorBlock:^(PO3ErrorID errorID) {
            self.falseToConnect = TRUE;

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
            [self scan];

        }];
        [po3 commandQueryBatteryInfo:^(BOOL resetSuc) {
            if (resetSuc){
                NSLog(@"Got battery percentage.");
            }
        } DisposeErrorBlock:^(PO3ErrorID errorID) {
            self.falseToConnect = TRUE;

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
            
            [self scan];

            
        } DisposeBattery:^(NSNumber * battery) {
            NSLog(@"This is the current device battery percentage %d%%",battery.intValue);
            self.BatteryInfo.hidden = NO;
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
            [AudioPlayer speak:@"Please remove the pulse oximeter from your finger." withSynthesizer:synthesizer];
            self.bottomHelpLabel.hidden = YES;
        }
        else
        {
//            NSInteger secondsRemaining = self.secondsRemaining - interval;
//            NSInteger minutes = (secondsRemaining % 3600) / 60;
//            NSInteger seconds = (secondsRemaining % 3600) % 60;
//            self.topHelpLabel.text = [NSString stringWithFormat:@"Please wait %ld:%02ld minutes and remove the pulse oximeter from your finger.", (long)minutes, (long)seconds];
            self.topHelpLabel.hidden = NO;
            self.bottomHelpLabel.hidden = YES;
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
    [[ScanDeviceController commandGetInstance] commandStopScanDeviceType:HealthDeviceType_PO3];
    
    NSString *serialNumber = [[info userInfo] objectForKey:@"SerialNumber"];
    NSString *ID = [[info userInfo] objectForKey:@"ID"];
    
    if (serialNumber != nil)
    {
        
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
    self.topHelpLabel.text = @"Place the pulse oximeter on any finger.  Rest your arms and hands comfortably.  Please hold still and do not move or talk.  Press the white button on the pulse oximeter firmly to turn on the display.";
    self.bottomHelpLabel.text = nil;
    self.statusLabel.hidden = NO;
    self.topHelpLabel.hidden = NO;
    self.bottomHelpLabel.hidden = NO;
    self.connectedImageView.hidden = NO;
    self.connectedImageView.image = [UIImage animatedImageNamed:@"oximeter-" duration:1.0f];
    self.spO2View.hidden = YES;
    self.pulseView.hidden = YES;
}

- (void)showDisconnectedView
{
    self.statusLabel.text = @"The device is not connected";
    self.topHelpLabel.text = @"Place the pulse oximeter on any finger.  Rest your arms and hands comfortably.  Press the button to start a measurement.";
    //self.bottomHelpLabel.text = @"Please make sure Bluetooth is turned on.";
    self.bottomHelpLabel.text = nil;
    self.statusLabel.hidden = NO;
    self.topHelpLabel.hidden = NO;
    //self.bottomHelpLabel.hidden = YES;
    self.connectedImageView.hidden = YES;
    self.spO2View.hidden = YES;
    self.pulseView.hidden = YES;
}

- (void)showMeasurementView
{
    //self.statusLabel.hidden = YES;
    //self.topHelpLabel.hidden = YES;
    //self.bottomHelpLabel.hidden = YES;
    self.connectedImageView.hidden = YES;
    self.spO2View.hidden = NO;
}

- (void)saveOxygenSaturation
{
    if (measurements.count > 0)
    {
//        double spO2 = 0.0;
//        double pulse = 0.0;
//        
//        for (OxygenSaturation *measurement in measurements)
//        {
//            spO2 += measurement.spO2.doubleValue;
//            pulse += measurement.heartRate.doubleValue;
//        }
//        
//        spO2 = spO2 / measurements.count;
//        pulse = pulse / measurements.count;
//        
//        OxygenSaturation *measurement = [OxygenSaturation new];
//        measurement.spO2 = [NSNumber numberWithDouble:spO2];
//        measurement.heartRate = [NSNumber numberWithInt:pulse];
        
        OxygenSaturation *measurement = [measurements lastObject];
        
        MBProgressHUD *hud = [Utility getHUDAddedTo:self.navigationController.view withText:@"Saving..."];
        [hud show:YES];
        
        //save to health kit
        [[HealthKitManager sharedManager] saveOxygenSaturation:measurement];
        
        [[UserManager sharedManager] saveOxygenSaturation:measurement completion:^(NSError *error) {
            [hud hide:YES];
            
            if (error != nil)
            {
                if ([[DbManager sharedManager] insertOxygenSaturation:measurement])
                {
                    [hud hide:YES];
                    
                }
                
                else
                {
                    [hud hide:YES];
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Save Failed!", nil)
                                                                                   message:NSLocalizedString(@"Please make sure you have a stable internet connection.", nil)
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                        
                        [alert dismissViewControllerAnimated:YES completion:^{}];
                    }];
                    
                    [alert addAction:ok];
                    [self presentViewController:alert animated:YES completion:nil];
                }
            }
            
            else{
                [hud hide:YES];
                self.skipButton.hidden = YES;
                self.topHelpLabel.text = @"Your Qxygen Saturation was successfully submitted.";
                [AudioPlayer speak:@"Your Qxygen Saturation was successfully submitted." withSynthesizer:synthesizer];
                self.statusLabel.hidden = YES;

            }
        }];
    }
    else
    {
        [self scan];
    }
}

- (void)authenticate
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Transmit Readings" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init] ;
    [paragraphStyle setAlignment:NSTextAlignmentLeft];
    
    NSMutableAttributedString *alertText = [[NSMutableAttributedString alloc] initWithString:@"Thank you!\n\nPlease push the OK button to transmit your readings to your healthcare team. We will be in touch with you if any changes are needed."];
    [alertText addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0,[alertText length])];
    
    [alertText addAttribute:NSFontAttributeName
                      value:[UIFont systemFontOfSize:22.0]
                      range:NSMakeRange(0,[alertText length])];
    
    [alert setValue:alertText forKey:@"attributedTitle"];
    
    UIAlertAction *ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action){
                                                   [self saveOxygenSaturation];
                                                   
                                                   [alert dismissViewControllerAnimated:YES completion:nil];                                                   }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showPasswordAlert
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Enter Passcode", nil)
                                                                   message:NSLocalizedString(@"Transmit readings to your healthcare team", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"Passcode";
        textField.secureTextEntry = YES;
        textField.keyboardType = UIKeyboardTypeNumberPad;
    }];
    
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        UITextField *passcode = alert.textFields.firstObject;
        NSString *pin = [JNKeychain loadValueForKey:@"pin"];
        
        if ([passcode.text isEqualToString:pin])
        {
            [self saveOxygenSaturation];
        }
        else
        {
            [self showPasswordAlert];
        }
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self checkSessionDidTimeout];
}


- (void)ShowSubmitButton
{
    
    //PO3 *po3 = [self getPO3];
    
    //Kills communication with the pulse oximeter.
    ///[po3 commandEndPO3CurrentConnect:nil DisposeErrorBlock:nil];
    
    [synthesizer stopSpeakingAtBoundary:AVSpeechBoundaryImmediate];
    
    [AudioPlayer speak:@"Connectivity issues? Push the blue button at the bottom of the screen to manually enter your oxygen saturation." withSynthesizer:synthesizer];
    self.skipButton.hidden = NO;
    self.BatteryInfo.hidden = true;
    self.statusLabel.text = @"Push the blue button.";
    self.connectedImageView.hidden = true;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
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
        [measurements addObject:measurement];
        
        [self authenticate];
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

@end
