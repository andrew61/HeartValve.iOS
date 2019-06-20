//
//  WeightVC.h
//  MyHealthApp
//
//  Created by Jonathan on 1/5/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreBluetoothDelegate.h"

@class AD_UC_352BLE;

@interface WeightVC : UIViewController<CoreBluetoothDelegate>

@property (strong, nonatomic) AD_UC_352BLE *scaleDevice;
@property (assign, nonatomic) BOOL weightInProgress;
@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (weak, nonatomic) IBOutlet UIView *weightView;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UIImageView *weightImageView;
@property (assign, nonatomic) BOOL stopSpeaking;

@end
