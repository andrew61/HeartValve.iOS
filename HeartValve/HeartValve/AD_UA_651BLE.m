#define DEVICE_NAME @"A&D_UA-651BLE"

//  MSS_AD_UA_651BLE.m
//  SEAMS
//  Created by Michael McEvoy on 2/21/15.
//  Copyright (c) 2015 Michael McEvoy. All rights reserved.
// Header import

#import <CoreBluetooth/CoreBluetooth.h>
#import "AD_UA_651BLE.h"
#import "BloodPressureMeasurement.h"

@implementation AD_UA_651BLE

- (instancetype)initWithDelegate:(id<CoreBluetoothDelegate>)delegate
{
    NSArray *services = [NSArray arrayWithObjects:
                     [CBUUID UUIDWithString:@"1810"],
                     [CBUUID UUIDWithString:@"180A"],
                     [CBUUID UUIDWithString:@"180F"],
                     [CBUUID UUIDWithString:@"233BF000-5A34-1B6D-975C-000D5690ABE4"],
                     nil];
    NSArray *characteristics = [NSArray arrayWithObject:[CBUUID UUIDWithString:@"2A35"]];
    
    return [super initWithDelegate:delegate deviceName:DEVICE_NAME services:services characteristics:characteristics];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([peripheral.name rangeOfString:DEVICE_NAME].location != NSNotFound)
    {
        NSData *valueData = characteristic.value;
        
        if (valueData != nil)
        {
            NSString *valueString = [[valueData description] stringByReplacingOccurrencesOfString:@" " withString:@""];
            valueString = [valueString substringWithRange:NSMakeRange(1, valueString.length - 2)];
            
            if (valueString.length > 15)
            {
                NSString *systolicString = [valueString substringWithRange:NSMakeRange(2, 2)];
                NSString *diastolicString = [valueString substringWithRange:NSMakeRange(6, 2)];
                NSString *mapString = [valueString substringWithRange:NSMakeRange(10, 2)];
                NSString *pulseString = [valueString substringWithRange:NSMakeRange(14, 2)];
                
                unsigned int systolic, diastolic, map, pulse;
                
                [[NSScanner scannerWithString:systolicString] scanHexInt:&systolic];
                [[NSScanner scannerWithString:diastolicString] scanHexInt:&diastolic];
                [[NSScanner scannerWithString:mapString] scanHexInt:&map];
                [[NSScanner scannerWithString:pulseString ] scanHexInt:&pulse];
                
                if ((pulse == 224 || pulse == 225) && valueString.length >= 30)
                {
                    pulseString = [valueString substringWithRange:NSMakeRange(28, 2)];
                    [[NSScanner scannerWithString:pulseString ] scanHexInt:&pulse];
                }
                
                self.reading = [[BloodPressureMeasurement alloc] initWithSystolic:systolic diastolic:diastolic map:map pulse:pulse];
                [self.delegate gotReading:self.reading];
            }
        }
    }
}

@end
