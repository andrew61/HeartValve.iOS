//
//  PulseOximeterPairingVC.m
//  HeartValve
//
//  Created by Jameson B on 10/31/17.
//  Copyright © 2017 MUSC. All rights reserved.
//

#define SDKClientID @"6a76ee9e601540f88fd5d12dace64d3e"
#define SDKClientSecret @"479eb06026b448ba84299bc61fa3f110"
#define SDKUserID @"tindalljon@hotmail.com"

#import "PulseOximeterPairingVC.h"
#import "POHeader.h"
#import "ScanDeviceController.h"
#import "Utility.h"
#import "UserManager.h"
#import "MBProgressHUD.h"
#import "HealthKitManager.h"
#import "DbManager.h"
#import "AudioPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "UIColor+Extensions.h"
#import "AppDelegate.h"
#import "JNKeychain.h"


@interface PulseOximeterPairingVC ()

@end

@implementation PulseOximeterPairingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.MacAddrText.delegate = self;

    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard:)];
    
    tapGestureRecognizer.cancelsTouchesInView = NO;
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
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    
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

- (void)scan
{
    PO3 *po3 = [self getPO3];
    
    if (po3 != nil)
    {
        HealthUser *user = [HealthUser new];
        
        user.clientID = SDKClientID;
        user.clientSecret = SDKClientSecret;
        user.userID = SDKUserID;
        
        
        [po3 commandCreatePO3User:user Authentication:nil DisposeResultBlock:^(BOOL finishSynchronous) {
            [po3 commandStartPO3MeasureData:^(BOOL startData) {
//                self.spO2InProgress = YES;
            } Measure:^(NSDictionary *measureDataDic) {
                
            } FinishPO3MeasureData:^(BOOL finishData) {
//                self.spO2InProgress = NO;
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
//                self.spO2InProgress = NO;
                
            }
             ];
        } DisposeErrorBlock:^(PO3ErrorID errorID) {
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
                self.ScanFeedText.text = [self.ScanFeedText.text stringByAppendingString:[NSString stringWithFormat:@"\n -Pulse Oximeter Battery Percentage: %d%%.",battery.intValue]];
        }];
        
    }
    else
    {
        [[ScanDeviceController commandGetInstance] commandScanDeviceType:HealthDeviceType_PO3];
    }
}

- (void)deviceDidConnect:(NSNotification *)info
{
    self.statusText.text = @"The device is connected.";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Device Found!", nil)
                                                                   message:NSLocalizedString(@"Do you want to save this device?", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yes = [UIAlertAction actionWithTitle:@"Yes" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    UIAlertAction *no = [UIAlertAction actionWithTitle:@"No/Disconnect" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:yes];
    [alert addAction:no];


    [self presentViewController:alert animated:YES completion:nil];
}

- (void)deviceDidDisconnect:(NSNotification *)info
{
    [[ScanDeviceController commandGetInstance] commandScanDeviceType:HealthDeviceType_PO3];
}

- (void)deviceDiscovered:(NSNotification *)info
{
    NSString *ID = [[info userInfo] objectForKey:@"ID"];
    NSString *serialNumber = [[info userInfo] objectForKey:@"SerialNumber"];
    NSLog(@"serialNumber TRUE: %@",[[info userInfo] objectForKey:@"SerialNumber"]);
    NSLog(@"Device ID TRUE: %@",ID);
    
    if ([serialNumber isEqualToString: self.MacAddrText.text])
    {
        [[ScanDeviceController commandGetInstance] commandStopScanDeviceType:HealthDeviceType_PO3];
        self.ScanFeedText.text = [self.ScanFeedText.text stringByAppendingString:@"\n -Pulse Oximeter Found."];
        [self.ScanButton setTitle:@"Rescan" forState:UIControlStateNormal];
        self.scanningText.hidden = YES;
        [[ConnectDeviceController commandGetInstance] commandContectDeviceWithDeviceType:HealthDeviceType_PO3 andSerialNub:serialNumber];
        
    }
    else
    {
//            [[ConnectDeviceController commandGetInstance] commandContectDeviceWithDeviceType:HealthDeviceType_PO3 andSerialNub:ID];
            self.ScanFeedText.text = [self.ScanFeedText.text stringByAppendingString:[NSString stringWithFormat:@"\n -Device not Found (%@).",serialNumber]];

    }
}

- (void)deviceDidFailToConnect:(NSNotification *)info
{
    self.ScanFeedText.text = [self.ScanFeedText.text stringByAppendingString:@"\n -Pulse Oximeter fail to connect. Rescanning..."];

    [self scan];
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (void)hideKeyboard:(UITapGestureRecognizer *)tapGestureRecognizer
{
    [self.view endEditing:YES];
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}

- (BOOL)shouldAutorotate
{
    return NO;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)ScanButtonPushed:(id)sender {
    [[ScanDeviceController commandGetInstance] commandStopScanDeviceType:HealthDeviceType_PO3];

    self.scanningText.hidden = NO;
    self.ScanFeedText.editable = NO;

    [self scan];
}
- (IBAction)BackButton:(id)sender {
    [[ScanDeviceController commandGetInstance] commandStopScanDeviceType:HealthDeviceType_PO3];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    
    PO3 *po3 = [self getPO3];
    
    if (po3 != nil)
    {
        [po3 commandEndPO3CurrentConnect:nil DisposeErrorBlock:nil];
    }
    [self dismissViewControllerAnimated:NO completion:nil];
}
@end
