//  MSSCoreBluetoothDevice.m
//  SEAMS
//  Created by Michael McEvoy on 2/21/15.
//  Copyright (c) 2015 Michael McEvoy. All rights reserved.
// Header import

#import <CoreBluetooth/CoreBluetooth.h>
#import "CoreBluetoothDevice.h"

@implementation CoreBluetoothDevice

- (instancetype)initWithDelegate:(id<CoreBluetoothDelegate>)delegate deviceName:(NSString *)deviceName services:(NSArray *)services characteristics:(NSArray *)characteristics
{
    self = [super init];
    if (self != nil)
    {
        self.delegate = delegate;
        self.deviceName = deviceName;
        self.services = services;
        self.characteristics = characteristics;
        self.bluetoothManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil];
    }
    return self;
}

- (void)connectWithTimeout:(int)timeout
{
    if (self.bluetoothManager.state == CBCentralManagerStatePoweredOn)
    {
        if (timeout > 0)
        {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:timeout target:self selector:@selector(deviceDidTimeout) userInfo:nil repeats:NO];
        }
        
//        if (self.peripheral != nil)
//        {
//            NSArray *knownPeripherals = [self.bluetoothManager retrievePeripheralsWithIdentifiers:[NSArray arrayWithObject:[CBUUID UUIDWithNSUUID:self.peripheral.identifier]]];
//            
//            if ([knownPeripherals count] > 0)
//            {
//                for (CBPeripheral *peripheral in knownPeripherals)
//                {
//                    if (peripheral.identifier == self.peripheral.identifier)
//                    {
//                        self.peripheral = peripheral;
//                        [self.bluetoothManager connectPeripheral:self.peripheral options:nil];
//                        return;
//                    }
//                }
//            }
//        }
        
        [self.bluetoothManager scanForPeripheralsWithServices:self.services options:nil];
    }
}

- (void)deviceDidTimeout
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(deviceDidTimeout)])
    {
        [self.delegate deviceDidTimeout];
    }
}

- (void)disconnect
{
    if (self.peripheral != nil)
    {
        [self.bluetoothManager cancelPeripheralConnection:self.peripheral];
    }
}

- (void)centralManagerDidUpdateState:(CBCentralManager *)central
{
    switch (central.state)
    {
        case CBCentralManagerStatePoweredOn:
            break;
        default:
            break;
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI
{
    NSString *localName = advertisementData[@"kCBAdvDataLocalName"];
    
    if (localName != nil && [localName rangeOfString:self.deviceName].location != NSNotFound)
    {
        [self.timer invalidate];
        
        self.peripheral = peripheral;
        [self.bluetoothManager stopScan];
        [self.bluetoothManager connectPeripheral:self.peripheral options:nil];
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral
{
    if (peripheral == self.peripheral)
    {
        [self.timer invalidate];
        
        peripheral.delegate = self;
        [self.delegate deviceDidConnect];
        [peripheral discoverServices:self.services];
    }
}

- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (peripheral == self.peripheral)
    {
        [self.delegate deviceDidFailToConnect];
    }
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    if (peripheral == self.peripheral)
    {
        [self.delegate deviceDidDisconnect];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    for (CBService *service in [peripheral services])
    {
        [peripheral discoverCharacteristics:self.characteristics forService:service];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error
{
    for (CBCharacteristic *characteristic in [service characteristics])
    {
        [peripheral setNotifyValue:YES forCharacteristic:characteristic];
    }
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (!characteristic.isNotifying)
    {
        [peripheral readValueForCharacteristic:characteristic];
    }
}

@end
