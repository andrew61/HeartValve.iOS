//
//  BPViewController.h
//  iHealthDemoCode
//
//  Created by zhiwei jing on 14-9-23.
//  Copyright (c) 2014年 zhiwei jing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BPHeader.h"

@interface BPViewController : UIViewController
{
    NSMutableArray *discoverBP3LDevices;
    NSMutableArray *discoverBP7SDevices;
    NSMutableArray *discoverKN550BTDevices;
    NSMutableArray *discoverKD926Devices;
    NSMutableArray *discoverKD723Devices;
    NSMutableArray *discoverABPMDevices;
    NSMutableArray *discoverHTSDevices;
    
}

@property (strong, nonatomic) NSString *currentKD926UUIDStr;
@property (strong, nonatomic) NSString *currentKD723UUIDStr;
@property (strong, nonatomic) NSString *currentABPMUUIDStr;

@property (weak, nonatomic) IBOutlet UITextView *tipTextView;
@property (strong, nonatomic) IBOutlet UIButton *kd926OfflineDataBtn;
@property (strong, nonatomic) IBOutlet UIButton *kd926EnergyBtn;
@property (strong, nonatomic) IBOutlet UIButton *kd723OfflineDataBtn;
@property (strong, nonatomic) IBOutlet UIButton *kd723EnergyBtn;
@property (strong, nonatomic) IBOutlet UIButton *abpmSetTimeIntervalBtn;
@property (strong, nonatomic) IBOutlet UIButton *abpmOfflineDataBtn;
@property (strong, nonatomic) IBOutlet UIButton *abpmEnergyBtn;
@property (strong, nonatomic) IBOutlet UIButton *startScanBP3LBotton;

-(IBAction)testBattary:(id)sender;

@end
