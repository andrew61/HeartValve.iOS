#define DEVICE_NAME @"A&D_UC-352BLE"

//  MSS_AD_UC_352BLE.m
//  SEAMS
//  Created by Michael McEvoy on 2/21/15.
//  Copyright (c) 2015 Michael McEvoy. All rights reserved.
// Header import

#import <CoreBluetooth/CoreBluetooth.h>
#import "AD_UC_352BLE.h"
#import "WeightMeasurement.h"

@implementation AD_UC_352BLE

- (instancetype)initWithDelegate:(id<CoreBluetoothDelegate>)delegate
{
    NSArray *services = [NSArray arrayWithObjects:
                         [CBUUID UUIDWithString:@"23434100-1FE4-1EFF-80CB-00FF78297D8B"],
                         [CBUUID UUIDWithString:@"180A"],
                         [CBUUID UUIDWithString:@"180F"],
                         [CBUUID UUIDWithString:@"233BF000-5A34-1B6D-975C-000D5690ABE4"],
                         nil];
    NSArray *characteristics = [NSArray arrayWithObject:[CBUUID UUIDWithString:@"23434101-1FE4-1EFF-80CB-00FF78297D8B"]];
    
    return [super initWithDelegate:delegate deviceName:DEVICE_NAME services:services characteristics:characteristics];
}

- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if ([peripheral.name rangeOfString:self.deviceName].location != NSNotFound)
    {
        NSData *valueData = characteristic.value;
        
        if (valueData != nil)
        {
            NSString *valueString = [[valueData description] stringByReplacingOccurrencesOfString:@" " withString:@""];
            valueString = [valueString substringWithRange:NSMakeRange(1, valueString.length - 2)];
            
            if (valueString.length > 5)
            {
                NSString *weight1String = [NSString stringWithFormat:@"%c%c%c", [valueString characterAtIndex:5], [valueString characterAtIndex:4], [valueString characterAtIndex:3]];
                NSString *weight2String = [NSString stringWithFormat:@"%c", [valueString characterAtIndex:2]];
                
                unsigned int weight1, weight2;
                
                [[NSScanner scannerWithString:weight1String] scanHexInt:&weight1];
                [[NSScanner scannerWithString:weight2String] scanHexInt:&weight2];
                
                float weight = (weight1 * 1.0f / 10.0f) + (weight2 * 1.6f);
                self.reading = [[WeightMeasurement alloc] initWithWeight:weight];
                [self.delegate gotReading:self.reading];
            }
        }
    }
}

@end