//  MSS_AD_UA_651BLE.h
//  SEAMS
//  Created by Michael McEvoy on 2/21/15.
//  Copyright (c) 2015 Michael McEvoy. All rights reserved.

#import "CoreBluetoothDevice.h"

@interface AD_UA_651BLE : CoreBluetoothDevice

- (instancetype)initWithDelegate:(id<CoreBluetoothDelegate>)delegate;

@end