//
//  AM4ViewController.m
//  iHealthDemoCode
//
//  Created by hejiasu on 16/5/19.
//  Copyright © 2016年 zhiwei jing. All rights reserved.
//

#import "AM4ViewController.h"
#import "ScanDeviceController.h"
#import "AMHeader.h"

@interface AM4ViewController ()
{
    AM4 *am4Instance;
    HealthUser *myUser;
    NSNumber *userIDNumber;
    NSNumber *randomNumber;
}
@end

@implementation AM4ViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceAM4Discover:) name:AM4Discover object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceAM4ConnectFailed:) name:AM4ConnectFailed object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceConnectForAM4:) name:AM4ConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceDisConnectForAM4:) name:AM4DisConnectNoti object:nil];

    [AM4Controller shareIHAM4Controller] ;

}

- (IBAction)scanDevice:(UIButton *)sender {
    
    ScanDeviceController *scan = [ScanDeviceController commandGetInstance];
    [scan commandScanDeviceType:HealthDeviceType_AM4];
}



- (IBAction)stopScan:(UIButton *)sender {
    
    ScanDeviceController *scan = [ScanDeviceController commandGetInstance];
    [scan commandStopScanDeviceType:HealthDeviceType_AM4];
}


-(void)deviceAM4Discover:(NSNotification *)info
{
    NSString *serialNub = [[info userInfo]valueForKey:@"SerialNumber"];
  
    
    [[ConnectDeviceController commandGetInstance]commandContectDeviceWithDeviceType:HealthDeviceType_AM4 andSerialNub:serialNub];
}

-(void)deviceAM4ConnectFailed:(NSNotification *)info
{
    
}


-(void)deviceDisConnectForAM4:(NSNotification *)info
{
    
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
    
    
}




-(void)deviceConnectForAM4:(NSNotification *)DeviceName
{
    
    AM4Controller *amController = [AM4Controller shareIHAM4Controller];
    NSArray *amArray = [amController getAllCurrentAM4Instace];
    
    
    if(amArray.count==1)
    {
        am4Instance = [amArray objectAtIndex:0];
        myUser = [[HealthUser alloc]init];
        myUser.clientID = SDKKey;
        myUser.clientSecret = SDKSecret;
        myUser.userID = YourUserName;
        
        [am4Instance commandAM4CreateUserManageConnectWithUser:myUser withAuthenticationResult:^(UserAuthenResult result) {
            
            NSLog(@"UserAuthenResult:%d",result);
            
        } withCurrentUserID:^(NSInteger serialNub) {
            
            NSLog(@"serialNub:%ld",(long)serialNub);
            
            userIDNumber = [NSNumber numberWithInt:serialNub];
            
            userIDNumber = @123456;
            
            [am4Instance commandAM4SyncTime:^(BOOL resetSuc) {
                
                NSLog(@"SyncTimeOk");
                
                [am4Instance commandAM4SetTimeFormatAndNation:^(BOOL timeFormatAndNationSetting) {
                    
                    NSLog(@"SetTimeFormatAndNationOk");
                    
                    
                    [am4Instance commandAM4GetDeviceUserID:^(unsigned int userID) {
                        
                        NSLog(@"GetDeviceUserID:%d",userID);
                        myUser.userID = [NSString stringWithFormat:@"%d",userID];
                        
                        
                    } withFromCloudGetUserBinedDeviceMAC:^(NSString *deviceMAC) {
                        
                        NSLog(@"FromCloudGetUserBinedDeviceMAC:%@",deviceMAC);
                        
                    
                        
                        if (userIDNumber.intValue == myUser.userID.intValue)
                        {
                            [self commandAM4SetUserInfo];
                        }
                        else{
                            
                            [am4Instance commandAM4SetRandomNumber:^(NSString *randomNumString) {
                                
                                NSLog(@"randomNumString:%@",randomNumString);
                                
                                
                                randomNumber = [NSNumber numberWithInt:[randomNumString intValue]];
                                
                                
                            } withErrorBlock:^(AM4ErrorID errorID) {
                                
                                NSLog(@"AMErrorID:%d",errorID);
                                
                            }];
                        }

                        
                    } withErrorBlock:^(AM4ErrorID errorID) {
                        
                        NSLog(@"AMErrorID:%d",errorID);
                        
                    }];

                    
                    
                } withErrorBlock:^(AM4ErrorID errorID) {
                    
                    NSLog(@"AMErrorID:%d",errorID);
                    
                }];
                
            } withErrorBlock:^(AM4ErrorID errorID) {
                
                NSLog(@"AMErrorID:%d",errorID);
                
            }];

            
            
        } withErrorBlock:^(AM4ErrorID errorID) {
            
            NSLog(@"AMErrorID:%d",errorID);
            
        }];
    }
}

- (void)commandAM4SetUserInfo
{
    myUser.birthday = [NSDate dateWithTimeIntervalSince1970:0];
    myUser.sex = UserSex_Male;
    myUser.height = @165;
    myUser.weight = @55;
    myUser.bmr = @120;
    myUser.lengthUnit = LengthUnit_Kilometer;
    myUser.activityLevel = @1;
    
    
    [am4Instance commandAM4SetUserInfo:myUser withUnit:AM4KmUnit_mile withActiveGoal:@30 withSwimmingGoal:@33 withSetUserInfoFinishResult:^(BOOL resetSuc) {
        NSLog(@"FinishResultok");

    } withSetBMR:^(BOOL resetSuc) {

        NSLog(@"SetBMR ok");

        [am4Instance commandAM4SetSwimmingState:YES withSwimmingPoolLength:@110 withNOSwimmingTime:[NSDate date] withUnit:AM4SwimmingUnit_km withFinishResult:^(BOOL resetSuc) {
            
            NSLog(@"SetSwimm ok");
            
        } withErrorBlock:^(AM4ErrorID errorID) {
            
            NSLog(@"AMErrorID:%d",errorID);
            
        }];

        
    } withErrorBlock:^(AM4ErrorID errorID) {
        NSLog(@"AMErrorID:%d",errorID);

    }];
    
}


-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if ([self.textField isFirstResponder]) {
        [self.textField resignFirstResponder];
    }
}


- (IBAction)setUserID:(id)sender
{
    if ([[NSString stringWithFormat:@"%@",randomNumber] isEqualToString:self.textField.text]) {
        
        [am4Instance commandAM4SetUserID:userIDNumber withFinishResult:^(BOOL resetSuc) {
            
            NSLog(@"SetUserIDok");
            
        } withSetCloudBinedDevice:^(BOOL resetSuc) {
            
            NSLog(@"CloudBinedDeviceok");
            
            [self commandAM4SetUserInfo];
            
            
        } withErrorBlock:^(AM4ErrorID errorID) {
            
            NSLog(@"AMErrorID:%d",errorID);
            
        }];
        
    }
}



- (IBAction)SyncActiveData:(UIButton *)sender {
    
    
    [am4Instance commandAM4StartSyncActiveData:^(NSDictionary *startDataDictionary) {
        
        NSLog(@"StartSyncActive --%@",startDataDictionary);

    } withActiveHistoryData:^(NSArray *historyDataArray) {
        
        NSLog(@"historyData --%@",historyDataArray);
        
    } withActiveFinishTransmission:^{
        
        NSLog(@"ok");

        
    } withErrorBlock:^(AM4ErrorID errorID) {
        NSLog(@"AMErrorID:%d",errorID);

    }];
    
    
}

- (IBAction)SyncSleepData:(id)sender {
    
    [am4Instance commandAM4StartSyncSleepData:^(NSDictionary *startDataDictionary) {
        NSLog(@"StartSyncSleep --%@",startDataDictionary);

    } withSleepHistoryData:^(NSArray *historyDataArray) {
        NSLog(@"historyData --%@",historyDataArray);

    } withSleepFinishTransmission:^{
        NSLog(@"ok");

    } withErrorBlock:^(AM4ErrorID errorID) {
        NSLog(@"AMErrorID:%d",errorID);

    }];
}

- (IBAction)SyncCurrentActive:(id)sender {
    
    
    [am4Instance commandAM4StartSyncCurrentActiveData:^(NSDictionary *activeDictionary) {
        NSLog(@"StartSyncCurrentActive --%@",activeDictionary);

    } withErrorBlock:^(AM4ErrorID errorID) {
        NSLog(@"AMErrorID:%d",errorID);

    }];
    
}

- (IBAction)SyncStageData:(id)sender {
    
//    [am4Instance commandAM4StartSyncStageDataCount:^(NSNumber *sportCount) {
//        NSLog(@"StartSyncStageData --%@",sportCount);
//
//    } withStageData:^(NSArray *measureDataArray) {
//        NSLog(@"historyData --%@",measureDataArray);
//
//    } withStageDataFinishTransmission:^(BOOL resetSuc) {
//        NSLog(@"ok");
//
//    } withErrorBlock:^(AM4ErrorID errorID) {
//        NSLog(@"AMErrorID:%d",errorID);
//
//    }];
    
}

- (IBAction)commandAM4GetDeviceStateInfo:(id)sender {
    [am4Instance commandAM4GetDeviceStateInfo:^(AM4QueryState queryState) {
        NSLog(@"DeviceStateInfo:%d",queryState);

    } withBattery:^(NSNumber *battery) {
        NSLog(@"battery:%d",battery.intValue);

    } withErrorBlock:^(AM4ErrorID errorID) {
        NSLog(@"AMErrorID:%d",errorID);

    }];
}

- (IBAction)commandAM4ResetDevice:(id)sender {
    [am4Instance commandAM4ResetDevice:^(BOOL resetSuc) {
        NSLog(@"ResetDevice Ok");

    } withFromCloudDisBinedDevice:^(BOOL resetSuc) {
        NSLog(@"DisBinedDevice Ok");

    } withErrorBlock:^(AM4ErrorID errorID) {
        NSLog(@"AMErrorID:%d",errorID);

    }];
}

- (IBAction)commandAM4Disconnect:(id)sender {
    
    [am4Instance commandAM4Disconnect:^(BOOL resetSuc) {
        
        NSLog(@"commandAM4Disconnect Ok");

        
    } withErrorBlock:^(AM4ErrorID errorID) {
        
        NSLog(@"AMErrorID:%d",errorID);

    }];
}

- (IBAction)commandAM4GetTotoalAlarmInfo:(id)sender {
    
    [am4Instance commandAM4GetTotoalAlarmInfo:^(NSMutableArray *totoalAlarmArray) {
        
        
        NSLog(@"GetTotoalAlarmInfo %@",totoalAlarmArray);

    } withErrorBlock:^(AM4ErrorID errorID) {
        
        NSLog(@"AMErrorID:%d",errorID);

    }];
    
    
}

- (IBAction)commandAM4SetAlarmDictionary:(id)sender {
    
    NSDictionary *tempClockDic = [NSDictionary dictionaryWithObjectsAndKeys:@2,@"AlarmId",@1,@"Sun",@"16:45",@"Time",@1,@"IsRepeat",@1,@"Switch",nil];

    
    [am4Instance commandAM4SetAlarmDictionary:tempClockDic withFinishResult:^(BOOL resetSuc) {
        
        NSLog(@"commandAM4SetAlarmDictionary ok");

    } withErrorBlock:^(AM4ErrorID errorID) {
        
        NSLog(@"AMErrorID:%d",errorID);

    }];
}

- (IBAction)commandAM4DeleteAlarmID:(id)sender {
    
    [am4Instance commandAM4DeleteAlarmID:@1 withFinishResult:^(BOOL resetSuc) {
   
        NSLog(@"commandAM4DeleteAlarmID ok");

    } withErrorBlock:^(AM4ErrorID errorID) {
        
        NSLog(@"AMErrorID:%d",errorID);

    }];
}

- (IBAction)commandAM4GetReminderInfo:(id)sender {
    
    [am4Instance commandAM4GetReminderInfo:^(NSArray *remindInfo) {
        
        NSLog(@"commandAM4GetReminderInfo %@",remindInfo);

        
    } withErrorBlock:^(AM4ErrorID errorID) {
        
        NSLog(@"AMErrorID:%d",errorID);

    }];
}

- (IBAction)commandAM4SetReminderDictionary:(id)sender {
    
    NSDictionary *tempReminderDic = [NSDictionary dictionaryWithObjectsAndKeys:@"00:01",@"Time",@1,@"Switch",nil];
    
    [am4Instance commandAM4SetReminderDictionary:tempReminderDic withFinishResult:^(BOOL resetSuc) {
        
        NSLog(@"SetReminderDictionary ok");

        
    } withErrorBlock:^(AM4ErrorID errorID) {
        
        NSLog(@"AMErrorID:%d",errorID);

    }];
    
}

- (IBAction)commandAM4GetTimeFormatAndNation:(id)sender {
    
    [am4Instance commandAM4GetTimeFormatAndNation:^(AM4TimeFormatAndNation timeFormatAndNation) {
        
        NSLog(@"commandAM4GetTimeFormatAndNation %u",timeFormatAndNation);

        
    } withErrorBlock:^(AM4ErrorID errorID) {
        
        NSLog(@"AMErrorID:%d",errorID);

    }];
}

- (IBAction)commandAM4GetUserInfo:(id)sender {
    
    [am4Instance commandAM4GetUserInfo:^(NSDictionary *userInfo) {
        
        NSLog(@"commandAM4GetUserInfo %@",userInfo);

        
    } withErrorBlock:^(AM4ErrorID errorID) {
        
        NSLog(@"AMErrorID:%d",errorID);

    }];
}

- (IBAction)commandAM4GetSwimmingInfo:(id)sender {
    
    [am4Instance commandAM4GetSwimmingInfo:^(BOOL swimmingIsOpen, NSNumber *swimmingLaneLength, NSNumber *NOSwimmingTime, AM4SwimmingUnit unit) {
        
        NSLog(@"commandAM4GetSwimmingInfo %hhd -%@-%@-%u",swimmingIsOpen,swimmingLaneLength,NOSwimmingTime,unit);

    } withErrorBlock:^(AM4ErrorID errorID) {
        
        NSLog(@"AMErrorID:%d",errorID);

    }];
}

- (IBAction)back:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}






















- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}





@end
