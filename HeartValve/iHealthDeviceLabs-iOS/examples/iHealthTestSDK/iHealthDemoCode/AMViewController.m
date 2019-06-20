//
//  AMViewController.m
//  iHealthDemoCode
//
//  Created by zhiwei jing on 14-9-23.
//  Copyright (c) 2014年 zhiwei jing. All rights reserved.
//

#import "AMViewController.h"
#import "ScanDeviceController.h"
#import "AM4ViewController.h"
@interface AMViewController ()

@end

@implementation AMViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}


-(void)deviceAM3Discover:(NSNotification *)info
{
    NSString *serialNub = [[info userInfo]valueForKey:@"SerialNumber"];
    [[ConnectDeviceController commandGetInstance]commandContectDeviceWithDeviceType:HealthDeviceType_AM3 andSerialNub:serialNub];
}


-(void)deviceAM3Siscover:(NSNotification *)info
{
    NSString *serialNub = [[info userInfo]valueForKey:@"SerialNumber"];
    [[ConnectDeviceController commandGetInstance]commandContectDeviceWithDeviceType:HealthDeviceType_AM3S andSerialNub:serialNub];
}

-(void)deviceAM4Discover:(NSNotification *)info
{
    NSString *serialNub = [[info userInfo]valueForKey:@"SerialNumber"];
    [[ConnectDeviceController commandGetInstance]commandContectDeviceWithDeviceType:HealthDeviceType_AM3S andSerialNub:serialNub];
}


-(void)deviceAM3ConnectFailed:(NSNotification *)info
{
    
}


-(void)deviceAM3SConnectFailed:(NSNotification *)info
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceAM3Discover:) name:AM3Discover object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceAM3Siscover:) name:AM3SDiscover object:nil];


    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceAM3ConnectFailed:) name:AM3ConnectFailed object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceAM3SConnectFailed:) name:AM3SConnectFailed object:nil];

    
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceConnectForAM3:) name:AM3ConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDisConnectForAM3:) name:AM3DisConnectNoti object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceConnectForAM3S:) name:AM3SConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDisConnectForAM3S:) name:AM3SDisConnectNoti object:nil];
    


    [AM3Controller shareIHAM3Controller];
    [AM3SController shareIHAM3SController];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)scanDevice:(UIButton *)sender{
    
    ScanDeviceController *scan = [ScanDeviceController commandGetInstance];
    [scan commandScanDeviceType:HealthDeviceType_AM3S];
}

- (IBAction)stopScan:(UIButton *)sender{
    
    ScanDeviceController *scan = [ScanDeviceController commandGetInstance];
    [scan commandStopScanDeviceType:HealthDeviceType_AM3S];

}




#pragma mark - AM3

-(void)DeviceConnectForAM3:(NSNotification *)tempNoti{
    AM3Controller *amController = [AM3Controller shareIHAM3Controller];
    NSArray *amArray = [amController getAllCurrentAM3Instace];
    
    if(amArray.count==1){
        AM3 *amInstance = [amArray objectAtIndex:0];
        tempAM3Instance = amInstance;
        HealthUser *myUser = [[HealthUser alloc]init];
        myUser.clientID = SDKKey;
        myUser.clientSecret = SDKSecret;
        myUser.userID = YourUserName;
        __block NSInteger yourUserSerialNub = 0;
        __block NSInteger amUserSerialNub = 0;
        __block NSString *yourBinedAMSerialNub = nil;
        [amInstance commandCreateUserManageConnectWithUser:myUser Authentication:^(UserAuthenResult result) {
            NSLog(@"UserAuthenResult:%d",result);
        } currentUserSerialNub:^(NSInteger serialNub) {
            NSLog(@"serialNub:%ld",(long)serialNub);
            yourUserSerialNub = serialNub;
        } amUser:^(unsigned int userID) {
            
            NSLog(@"userID:%d",userID);
            amUserSerialNub = userID;
            
            
            [amInstance commandsetAM3UserID:@123456789 DisposeBlock:^(BOOL resetSuc) {
                NSLog(@"Bined user:%d",resetSuc);
                if (resetSuc == true) {
                    //update userInfo
                    [self commandUpdateUserInfo:myUser forAM:amInstance];
                }
            } DisposeErrorBlock:^(AMErrorID errorID) {
                NSLog(@"Bined user error:%d",errorID);
            }];
            
        } binedAMSerialNub:^(NSString *binedSerialNub) {
            
            NSLog(@"binedSerialNub:%@",binedSerialNub);
            yourBinedAMSerialNub = binedSerialNub;
            
        } currentSerialNub:^(NSString *currentSerialNub) {
            NSLog(@"currentSerialNub:%@",currentSerialNub);
            
            
            
            
            
        
        } DisposeErrorBlock:^(AMErrorID errorID) {
            NSLog(@"AMErrorID:%d",errorID);
        }];
        
    }
}

-(void)commandUpdateUserInfo:(HealthUser *)myUser forAM:(AM3 *)amInstance{
    myUser.birthday = [NSDate dateWithTimeIntervalSince1970:0];
    myUser.sex = UserSex_Male;
    myUser.height = @165;
    myUser.weight = @55;
    myUser.bmr = @120;
    myUser.lengthUnit = LengthUnit_Mile;
    [amInstance commandSyncUserInfoWithUser:myUser andGoal:@1000 DisposeStateInfo:^(QueryAM3State queryState) {
        NSLog(@"QueryAM3State:%d",queryState);
    } DisposeBattery:^(NSNumber *battery) {
        NSLog(@"battery:%@",battery);
    } DisposeBlock:^(BOOL resetSuc) {
        NSLog(@"resetSuc:%d",resetSuc);
        
        //upload sport data and sleep  data
        [amInstance commandSyncAllAMData:^(NSDictionary *startDataDictionary) {
            NSLog(@"startDataDictionary:%@",startDataDictionary);
        } DisposeProgress:^(NSNumber *progress) {
            NSLog(@"DisposeProgress:%@",progress);
        } historyData:^(NSArray *historyDataArray) {
            NSLog(@"historyData:%@",historyDataArray);
        } FinishTransmission:^{
            NSLog(@"FinishTransmission");
        } startsleepdata:^(NSDictionary *startDataDictionary) {
            NSLog(@"startsleepdata:%@",startDataDictionary);
        } DisposeSleepProgress:^(NSNumber *progress) {
            NSLog(@"DisposeProgress:%@",progress);
        } sleephistoryData:^(NSArray *historyDataArray) {
            NSLog(@"historyData:%@",historyDataArray);
        } FinishSleepTransmission:^{
            NSLog(@"FinishSleepTransmission");
        } CurrentActiveInfo:^(NSDictionary *activeDictionary) {
            NSLog(@"CurrentActiveInfo:%@",activeDictionary);
        } DisposeErrorBlock:^(AMErrorID errorID) {
            NSLog(@"AMErrorID:%d",errorID);
        } AM3IsOnTransmission:^(BOOL isTransmiting) {
            ;
        } SleepIsOnTransmission:^(BOOL isTransmiting) {
            ;
        }];

    } DisposeErrorBlock:^(AMErrorID errorID) {
        NSLog(@"AMErrorID:%d",errorID);
    }];
}

-(void)DeviceDisConnectForAM3:(NSNotification *)tempNoti{
    
    
}

- (IBAction)AM3_ClockQuery:(id)sender {
    if (tempAM3Instance != nil) {
        [tempAM3Instance commandQueryAlarmInfo:^(NSMutableArray *totoalAlarmArray) {
            NSLog(@"totoalAlarmArray:%@",totoalAlarmArray);
            
            //set clock
            NSDictionary *tempClockDic = [NSDictionary dictionaryWithObjectsAndKeys:@1,@"AlarmId",@1,@"Sun",@"17:45",@"Time",@1,@"IsRepeat",@1,@"Switch",nil];
            [tempAM3Instance commandSetAlarmWithAlarmDictionary:tempClockDic DisposeResultBlock:^(BOOL resetSuc) {
                NSLog(@"DisposeResultBlock:%d",resetSuc);
            } DisposeErrorBlock:^(AMErrorID errorID) {
                NSLog(@"AMErrorID:%d",errorID);
            }];
            
        } DisposeErrorBlock:^(AMErrorID errorID) {
            NSLog(@"AMErrorID:%d",errorID);
        }];
    }
}

- (IBAction)AM3_ReminderQuery:(id)sender {
    if (tempAM3Instance != nil) {
        [tempAM3Instance commandQueryReminder:^(NSArray *remindInfo) {
            NSLog(@"remindInfo:%@",remindInfo);
            
            NSDictionary *tempReminderDic = [NSDictionary dictionaryWithObjectsAndKeys:@"00:01",@"Time",@1,@"Switch",nil];
            //Set reminder
            
            [tempAM3Instance commandSetReminderwithReminderDictionary:tempReminderDic DisposeResultBlock:^(BOOL resetSuc) {
                NSLog(@"DisposeResultBlock:%d",resetSuc);
            } DisposeErrorBlock:^(AMErrorID errorID) {
                NSLog(@"AMErrorID:%d",errorID);
            }];
        } DisposeErrorBlock:^(AMErrorID errorID) {
            NSLog(@"AMErrorID:%d",errorID);
        }];
    }
}

- (IBAction)AM3_Reset:(id)sender {
    if (tempAM3Instance != nil) {
        [tempAM3Instance commandResetDeviceDisposeResultBlock:^(BOOL resetSuc) {
            NSLog(@"ResetDevic:%d",resetSuc);
        } DisposeErrorBlock:^(AMErrorID errorID) {
            NSLog(@"AMErrorID:%d",errorID);
        }];
    }
}


#pragma mark - AM3S

-(void)DeviceConnectForAM3S:(NSNotification *)DeviceName{
    
    NSString *deviceName = [[DeviceName userInfo] objectForKey:@"DeviceName"];
    
    if ([deviceName isEqualToString:@"AM3S"])
    {
        AM3SController *amController = [AM3SController shareIHAM3SController];
        NSArray *amArray = [amController getAllCurrentAM3SInstace];
        
        if(amArray.count==1){
            AM3S *amInstance = [amArray objectAtIndex:0];
            tempAM3SInstance = amInstance;
            HealthUser *myUser = [[HealthUser alloc]init];
            myUser.clientID = SDKKey;
            myUser.clientSecret = SDKSecret;
            myUser.userID = YourUserName;
            __block NSInteger yourUserSerialNub = 0;
            __block NSInteger amUserSerialNub = 0;
            __block NSString *yourBinedAMSerialNub = nil;
            [amInstance commandCreateUserManageConnectWithUser:myUser Authentication:^(UserAuthenResult result) {
                NSLog(@"UserAuthenResult:%d",result);
            } currentUserSerialNub:^(NSInteger serialNub) {
                NSLog(@"serialNub:%ld",(long)serialNub);
                yourUserSerialNub = serialNub;
                tempCloudUserSerialNub = serialNub;
            } amUser:^(unsigned int userID) {
                NSLog(@"userID:%d",userID);
                amUserSerialNub = userID;
                
            } binedAMSerialNub:^(NSString *binedSerialNub) {
                NSLog(@"binedSerialNub:%@",binedSerialNub);
                yourBinedAMSerialNub = binedSerialNub;
            } currentSerialNub:^(NSString *currentSerialNub) {
                NSLog(@"currentSerialNub:%@",currentSerialNub);
                
                [amInstance commandSetRandomString:^(BOOL resetSucSetting) {
                    NSLog(@"resetSucSetting:%d",resetSucSetting);
                    //read randomString from AM, bined user again
                    //.....- (IBAction)AM3S_BinedUser:(id)sender
                    
                } DisposeErrorBlock:^(AM3SErrorID errorID) {
                    NSLog(@"AMErrorID:%d",errorID);
                }];
                
            } DisposeErrorBlock:^(AM3SErrorID errorID) {
                NSLog(@"AMErrorID:%d",errorID);
            }];
            
        }

    }
}

- (IBAction)AM3S_BinedUser:(id)sender {
    
    [self.randomTextField resignFirstResponder];
    
    
    if (tempAM3SInstance != nil) {
        [tempAM3SInstance commandSetAM3SUserID:@123456789 withRandom:self.randomTextField.text DisposeBlock:^(BOOL resetSuc) {
            
            
            NSLog(@"Bined user:%d",resetSuc);
            
            HealthUser *myUser = [[HealthUser alloc]init];
            
            //update userInfo
            [self commandUpdateUserInfo:myUser forAM3S:tempAM3SInstance];
            
        } DisposeErrorBlock:^(AM3SErrorID errorID) {
            NSLog(@"Bined user error:%d",errorID);
        }];
    }
    
    
}


-(void)DeviceDisConnectForAM3S:(NSNotification *)tempNoti{
    

    tempAM3SInstance = nil;
    
}


-(void)commandUpdateUserInfo:(HealthUser *)myUser forAM3S:(AM3S *)amInstance{
    myUser.birthday = [NSDate dateWithTimeIntervalSince1970:0];
    myUser.sex = UserSex_Male;
    myUser.height = @165;
    myUser.weight = @55;
    myUser.bmr = @120;
    myUser.lengthUnit = LengthUnit_Kilometer;
    [amInstance commandSyncUserInfoWithUser:myUser andGoal:@30 DisposeStateInfo:^(QueryAM3SState queryState) {
        NSLog(@"QueryAM3State:%d",queryState);
    } DisposeBattery:^(NSNumber *battery) {
        NSLog(@"battery:%@",battery);
    } DisposeBlock:^(BOOL resetSuc) {
        NSLog(@"resetSuc:%d",resetSuc);
        
        
        //upload sport data and sleep  data
        [amInstance commandSyncAllAM3SData:^(NSDictionary *startDataDictionary) {
            NSLog(@"startDataDictionary:%@",startDataDictionary);
        } DisposeProgress:^(NSNumber *progress) {
            NSLog(@"DisposeProgress:%@",progress);
        } historyData:^(NSArray *historyDataArray) {
            NSLog(@"historyData:%@",historyDataArray);
        } FinishTransmission:^{
            NSLog(@"FinishTransmission");
        } startsleepdata:^(NSDictionary *startDataDictionary) {
            NSLog(@"startsleepdata:%@",startDataDictionary);
        } DisposeSleepProgress:^(NSNumber *progress) {
            NSLog(@"DisposeProgress:%@",progress);
        } sleephistoryData:^(NSArray *historyDataArray) {
            NSLog(@"historyData:%@",historyDataArray);
        } FinishSleepTransmission:^{
            NSLog(@"FinishSleepTransmission");
        } CurrentActiveInfo:^(NSDictionary *activeDictionary) {
            NSLog(@"CurrentActiveInfo:%@",activeDictionary);
            //Upload report
            
            [self commandUploadReportForAM3S:amInstance];
            
        } DisposeErrorBlock:^(AM3SErrorID errorID) {
            NSLog(@"AMErrorID:%d",errorID);
        } AM3SIsOnTransmission:^(BOOL isTransmiting) {
            ;
        } SleepIsOnTransmission:^(BOOL isTransmiting) {
            ;
        }];

        
    } DisposeErrorBlock:^(AM3SErrorID errorID) {
        NSLog(@"AMErrorID:%d",errorID);
    }];
}
-(void)commandUploadReportForAM3S:(AM3S *)amInstance{
    [amInstance commandSetSyncsportCount:^(NSNumber *sportCount) {
        NSLog(@"sportCount:%@",sportCount);
    } DisposeMeasureData:^(NSArray *measureDataArray) {
        NSLog(@"measureDataArray:%@",measureDataArray);
    } disposeFinishMeasure:^(BOOL finishUpload) {
        NSLog(@"finishUpload:%d",finishUpload);
    } DisposeErrorBlock:^(AM3SErrorID errorID) {
        NSLog(@"AMErrorID:%d",errorID);
    }];
}


- (IBAction)AM3S_ClockQuery:(id)sender {
    

        if (tempAM3SInstance != nil) {
            [tempAM3SInstance commandQueryAlarmInfo:^(NSMutableArray *totoalAlarmArray) {
                NSLog(@"totoalAlarmArray:%@",totoalAlarmArray);
                
                //set clock
                NSDictionary *tempClockDic = [NSDictionary dictionaryWithObjectsAndKeys:@2,@"AlarmId",@1,@"Sun",@"16:45",@"Time",@1,@"IsRepeat",@1,@"Switch",nil];
                [tempAM3SInstance commandSetAlarmWithAlarmDictionary:tempClockDic DisposeResultBlock:^(BOOL resetSuc) {
                    NSLog(@"DisposeResultBlock:%d",resetSuc);
                } DisposeErrorBlock:^(AM3SErrorID errorID) {
                    NSLog(@"AMErrorID:%d",errorID);
                }];
                
            } DisposeErrorBlock:^(AM3SErrorID errorID) {
                NSLog(@"AMErrorID:%d",errorID);
            }];
        }
    
}

- (IBAction)AM3S_ReminderQuery:(id)sender {
    

        if (tempAM3SInstance != nil) {
            [tempAM3SInstance commandQueryReminder:^(NSArray *remindInfo) {
                NSLog(@"remindInfo:%@",remindInfo);
                
                NSDictionary *tempReminderDic = [NSDictionary dictionaryWithObjectsAndKeys:@"00:01",@"Time",@1,@"Switch",nil];
                //Set reminder
                
                [tempAM3SInstance commandSetReminderwithReminderDictionary:tempReminderDic DisposeResultBlock:^(BOOL resetSuc) {
                    NSLog(@"DisposeResultBlock:%d",resetSuc);
                } DisposeErrorBlock:^(AM3SErrorID errorID) {
                    NSLog(@"AMErrorID:%d",errorID);
                }];
            } DisposeErrorBlock:^(AM3SErrorID errorID) {
                NSLog(@"AMErrorID:%d",errorID);
            }];
        }
    
}

- (IBAction)AM3S_Reset:(id)sender {
    

        if (tempAM3SInstance != nil) {
            [tempAM3SInstance commandResetDeviceDisposeResultBlock:^(BOOL resetSuc) {
                NSLog(@"ResetDevic:%d",resetSuc);
            } DisposeErrorBlock:^(AM3SErrorID errorID) {
                NSLog(@"AMErrorID:%d",errorID);
            }];
        }

    
   
}
- (IBAction)touchBackgroundPressed:(id)sender {
    [self.randomTextField resignFirstResponder];
}





- (IBAction)pushAM4:(UIButton *)sender {
    
    
    AM4ViewController *am = [[AM4ViewController alloc]init];
    [self presentViewController:am animated:YES completion:nil];

    
}
@end
