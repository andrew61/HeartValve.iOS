//
//  WeightScalePairingVC.h
//  HeartValve
//
//  Created by Jameson B on 10/31/17.
//  Copyright © 2017 MUSC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoreBluetoothDelegate.h"

@class AD_UC_352BLE;

@interface WeightScalePairingVC : UIViewController<CoreBluetoothDelegate>
@property (strong, nonatomic) AD_UC_352BLE *scaleDevice;

@end
