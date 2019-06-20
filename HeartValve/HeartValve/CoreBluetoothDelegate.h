//  MSSCoreBluetoothReadingDelegate.h
//  SEAMS
//  Created by Michael McEvoy on 2/21/15.
//  Copyright (c) 2015 Michael McEvoy. All rights reserved.

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

@protocol CoreBluetoothDelegate <NSObject>

- (void)deviceDidConnect;
- (void)deviceDidFailToConnect;
- (void)deviceDidDisconnect;
- (void)deviceDidTimeout;
- (void)gotReading:(id)reading;

@end