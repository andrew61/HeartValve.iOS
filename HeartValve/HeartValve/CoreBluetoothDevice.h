//  MSSCoreBluetoothDevice.h
//  SEAMS
//  Created by Michael McEvoy on 2/21/15.
//  Copyright (c) 2015 Michael McEvoy. All rights reserved.

#import <Foundation/Foundation.h>
#import "CoreBluetoothDelegate.h"
#import <CoreBluetooth/CoreBluetooth.h>

@interface CoreBluetoothDevice : NSObject <CBCentralManagerDelegate, CBPeripheralDelegate>

@property (strong, nonatomic) CBCentralManager *bluetoothManager;
@property (strong, nonatomic) CBPeripheral *peripheral;
@property (weak, nonatomic) id <CoreBluetoothDelegate> delegate;
@property (strong, nonatomic) id reading;
@property (copy, nonatomic) NSString *deviceName;
@property (strong, nonatomic) NSArray *services;
@property (strong, nonatomic) NSArray *characteristics;
@property (strong, nonatomic) NSTimer *timer;

- (instancetype)initWithDelegate:(id<CoreBluetoothDelegate>)delegate deviceName:(NSString *)deviceName services:(NSArray *)services characteristics:(NSArray *)characteristics;
- (void)connectWithTimeout:(int)timeout;
- (void)disconnect;

@end