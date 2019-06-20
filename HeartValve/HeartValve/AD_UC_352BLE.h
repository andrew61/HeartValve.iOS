//  MSS_AD_UC_352BLE.h
//  SEAMS
//  Created by Michael McEvoy on 2/21/15.
//  Copyright (c) 2015 Michael McEvoy. All rights reserved.

#import "CoreBluetoothDevice.h"

@interface AD_UC_352BLE : CoreBluetoothDevice

- (instancetype)initWithDelegate:(id<CoreBluetoothDelegate>)delegate;

@end