//
//  BloodPressureVC.h
//  MyHealthApp
//
//  Created by Jonathan on 1/5/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreBluetoothDelegate.h"

@class AD_UA_651BLE;

@interface BloodPressureVC : UIViewController<CoreBluetoothDelegate>

@property (strong, nonatomic) AD_UA_651BLE *bpDevice;
@property (assign, nonatomic) BOOL bpInProgress;
@property (assign, nonatomic) NSInteger bpAttempt;
@property (assign, nonatomic) NSInteger bpSecondsRemaining;
@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *systolicLabel;
@property (weak, nonatomic) IBOutlet UILabel *diastolicLabel;
@property (weak, nonatomic) IBOutlet UILabel *pulseLabel;
@property (weak, nonatomic) IBOutlet UIView *systolicView;
@property (weak, nonatomic) IBOutlet UIView *diastolicView;
@property (weak, nonatomic) IBOutlet UIView *pulseView;
@property (weak, nonatomic) IBOutlet UIImageView *startButtonImageView;
@property (assign, nonatomic) BOOL stopSpeaking;


@end
