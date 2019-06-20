//
//  BGViewController.m
//  iHealthDemoCode
//
//  Created by zhiwei jing on 14-9-23.
//  Copyright (c) 2014年 zhiwei jing. All rights reserved.
//

#import "BGViewController.h"
#import "BGHeader.h"
#import "HealthHeader.h"
#import "ConnectDeviceController.h"
#import "ScanDeviceController.h"

@interface BGViewController ()

@end

@implementation BGViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _tipTextView.editable=NO;
    discoverBG5LDevices=[[NSMutableArray alloc]init];
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceConnectForBG1:) name:BG1ConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDisConnectForBG1:) name:BG1DisConnectNoti object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceConnectForBG3:) name:BG3ConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDisConnectForBG3:) name:BG3DisConnectNoti object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceConnectForBG5:) name:BG5ConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDisConnectForBG5:) name:BG5DisConnectNoti object:nil];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceConnectForBG5L:) name:BG5LConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDisConnectForBG5L:) name:BG5LDisConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceBG5LDiscover:) name:BG5LDiscover object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceBG5LConnectFailed:) name:BG5LConnectFailed object:nil];
    
    [[BG1Controller shareBG1Controller]initBGAudioModule];
    [BG3Controller shareIHBg3Controller];
    [BG5Controller shareIHBg5Controller];
    [BG5LController shareIHBg5lController];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
 {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)InitiateAudioLayer:(id)sender {
    [[BG1Controller shareBG1Controller]initBGAudioModule];
}

- (IBAction)DestroyAudioLayer:(id)sender {
    [[BG1Controller shareBG1Controller]stopBGAudioModule];
}

-(void)DeviceConnectForBG1:(NSNotification *)tempNoti{
    BG1 *bgInstance = [[BG1Controller shareBG1Controller]getCurrentBG1Instance];
    if(bgInstance != nil){
        [bgInstance commandConnectBGwithDeviceModel:@0x00FF1304 DisposeDiscoverBlock:^(BOOL result) {
            NSLog(@"DisposeDiscoverBG1Block:%d",result);
            _tipTextView.text = [NSString stringWithFormat:@"DisposeDiscoverBG1Block:%d",result];
        } DisposeBGIDPSBlock:^(NSDictionary *idpsDic) {
            NSLog(@"idpsDic:%@",idpsDic);
            _tipTextView.text = [NSString stringWithFormat:@"idpsDic:%@",idpsDic];
        } DisposeConnectBGBlock:^(BOOL result) {
            if(result==true){
                [bgInstance commandCreateBGtestWithUser:YourUserName clientID:SDKKey clientSecret:SDKSecret Authentication:^(UserAuthenResult result) {
                    NSLog(@"Authentication Result:%d",result);
                    _tipTextView.text = [NSString stringWithFormat:@"Authentication Result:%d",result];
                }WithCode:CodeStr DisposeBGSendCodeBlock:^(BOOL sendOk) {
                    NSLog(@"DisposeBGSendCodeBlock:%d",sendOk);
                    _tipTextView.text = [NSString stringWithFormat:@"DisposeBGSendCodeBlock:%d",sendOk];
                } DisposeBGStripInBlock:^(BOOL stripIn) {
                    NSLog(@"stripIn:%d",stripIn);
                    _tipTextView.text = [NSString stringWithFormat:@"stripIn:%d",stripIn];
                } DisposeBGBloodBlock:^(BOOL blood) {
                    NSLog(@"blood:%d",blood);
                    _tipTextView.text = [NSString stringWithFormat:@"blood:%d",blood];
                } DisposeBGResultBlock:^(NSDictionary *result) {
                    NSLog(@"result:%@",result);
                    _tipTextView.text = [NSString stringWithFormat:@"result:%@",result];
                }DisposeBGStripOutBlock:^(BOOL stripOut) {
                    NSLog(@"stripOut:%d",stripOut);
                    _tipTextView.text = [NSString stringWithFormat:@"stripOut:%d",stripOut];
                } DisposeBGErrorBlock:^(NSNumber *errorID) {
                    NSLog(@"errorID:%@",errorID);
                    _tipTextView.text = [NSString stringWithFormat:@"errorID:%@",errorID];
                }];
            }
        } DisposeBGErrorBlock:^(NSNumber *errorID) {
            
        }];
    }
}

-(void)DeviceDisConnectForBG1:(NSNotification *)tempNoti{
    
}

-(void)DeviceConnectForBG3:(NSNotification *)tempNoti{
    _tipTextView.text = [[tempNoti userInfo]description];
    BG3 *bgInstance = [[BG3Controller shareIHBg3Controller]getCurrentBG3Instace];
    
    if(bgInstance != nil){
        [bgInstance commandCreateBG3TestModel:BGMeasureMode_Blood CodeString:CodeStr UserID:YourUserName clientID:SDKKey clientSecret:SDKSecret Authentication:^(UserAuthenResult result) {
            _tipTextView.text = [NSString stringWithFormat:@"%@\n UserAuthenResult:%d",_tipTextView.text,result];
        } DisposeBGSendCodeBlock:^(BOOL sendOk) {
            _tipTextView.text = [NSString stringWithFormat:@"%@\n sendOk:%d",_tipTextView.text,sendOk];
        } DisposeBGStripInBlock:^(BOOL stripIn) {
            _tipTextView.text = [NSString stringWithFormat:@"%@\n stripIn:%d",_tipTextView.text,stripIn];
        } DisposeBGBloodBlock:^(BOOL blood) {
            _tipTextView.text = [NSString stringWithFormat:@"%@\n blood:%d",_tipTextView.text,blood];
        } DisposeBGResultBlock:^(NSDictionary *result) {
            _tipTextView.text = [NSString stringWithFormat:@"%@\n result:%@",_tipTextView.text,result];
        } DisposeBGErrorBlock:^(NSNumber *errorID) {
            _tipTextView.text = [NSString stringWithFormat:@"%@\n errorID:%@",_tipTextView.text,errorID];
        }];
    }
    else{
        _tipTextView.text = @"Invalidate BG3 Info";
    }
}

-(void)DeviceDisConnectForBG3:(NSNotification *)tempNoti{
    
}

-(void)DeviceConnectForBG5:(NSNotification *)tempNoti{
    BG5Controller *bgController = [BG5Controller shareIHBg5Controller];
    NSArray *bgArray = [bgController getAllCurrentBG5Instace];
    
    if(bgArray.count>0){
        BG5 *bgInstance = [bgArray objectAtIndex:0];
        
        NSDictionary *codeDic = [bgInstance codeStripStrAnalysis:CodeStr];
        NSNumber *yourBottle = [codeDic valueForKey:@"BottleID"];
        
        
        [bgInstance commandInitBGSetUnit:BGUnit_mmolPL BGUserID:YourUserName clientID:SDKKey clientSecret:SDKSecret Authentication:^(UserAuthenResult result) {
            if(result== UserAuthen_CombinedSuccess || result== UserAuthen_LoginSuccess || result== UserAuthen_RegisterSuccess || result== UserAuthen_TrySuccess){
                NSLog(@"verify success");
            }
            else{
                NSLog(@"Verify failed");
            }
        } DisposeBGBottleID:^(NSNumber *bottleID) {
            //same code
            if (bottleID.integerValue == yourBottle.integerValue) {
                //read code
                [bgInstance commandReadBGCodeDic:^(NSDictionary *codeDic) {
                    NSLog(@"codeDic:%@",codeDic);
                    [self commandSendCode:bgInstance];
                } DisposeBGErrorBlock:^(NSNumber *errorID) {
                    NSLog(@"errorID:%@",errorID);
                }];
            }
            //different code
            else{
                NSLog(@"codeDic:%@",codeDic);
                [self commandSendCode:bgInstance];
            }
        } DisposeBGErrorBlock:^(NSNumber *errorID) {
            NSLog(@"errorID:%@",errorID);
        }];
    }
}

-(void)DeviceDisConnectForBG5:(NSNotification *)tempNoti{
    
}
-(void)commandSendCode:(BG5 *)bgInstance{
    NSDictionary *codeDic = [bgInstance codeStripStrAnalysis:CodeStr];
    NSNumber *yourBottle = [codeDic valueForKey:@"BottleID"];
    NSDate *yourValidDate = [codeDic valueForKey:@"DueDate"];
    NSNumber *yourRemainNub = [codeDic valueForKey:@"StripNum"];
    
    //send code
    [bgInstance commandSendBGCodeString:CodeStr bottleID:yourBottle validDate:yourValidDate remainNum:yourRemainNub DisposeBGSendCodeBlock:^(BOOL sendOk) {
        NSLog(@"send code success");
    } DisposeBGStartModel:^(BGOpenMode model) {
        NSLog(@"BGOpenMode:%d",model);
        //strip open mode
        if (model==BGOpenMode_Hand) {
            //start measure mode 0
            [bgInstance commandCreateBGtestModel:BGMeasureMode_Blood DisposeBGStripInBlock:^(BOOL stripIn) {
                NSLog(@"stripIn");
            } DisposeBGBloodBlock:^(BOOL blood) {
                NSLog(@"blood");
            } DisposeBGResultBlock:^(NSDictionary *result) {
                NSLog(@"result:%@",result);
            } DisposeBGTestModelBlock:^(BGMeasureMode model) {
                //0
                //1 blood mode
                NSLog(@"BGMeasureMode:%d",model);
            } DisposeBGErrorBlock:^(NSNumber *errorID) {
                NSLog(@"errorID:%@",errorID);
            }];
        }
        else{
            //start measure mode 1
            [bgInstance commandCreateBGtestStripInBlock:^(BOOL stripIn) {
                NSLog(@"stripIn");
            } DisposeBGBloodBlock:^(BOOL blood) {
                NSLog(@"blood");
            } DisposeBGResultBlock:^(NSDictionary *result) {
                NSLog(@"result:%@",result);
            } DisposeBGTestModelBlock:^(BGMeasureMode model) {
                //0
                //1 blood mode
                NSLog(@"BGMeasureMode:%d",model);
            } DisposeBGErrorBlock:^(NSNumber *errorID) {
                NSLog(@"errorID:%@",errorID);
            }];
        }
        
    } DisposeBGErrorBlock:^(NSNumber *errorID) {
        NSLog(@"errorID:%@",errorID);
    }];
    
}


- (IBAction)getBG5Memory:(id)sender {
    BG5Controller *bgController = [BG5Controller shareIHBg5Controller];
    NSArray *bgArray = [bgController getAllCurrentBG5Instace];
    
    if(bgArray.count>0){
        BG5 *bgInstance = [bgArray objectAtIndex:0];
        [bgInstance commandTransferMemorryData:^(NSNumber *dataCount) {
            NSLog(@"dataCount:%@",dataCount);
        } DisposeBGHistoryData:^(NSDictionary *historyDataDic) {
            NSLog(@"historyDataDic:%@",historyDataDic);
            [bgInstance commandDeleteMemorryData:^(BOOL deleteOk) {
                NSLog(@"deleteOk:%d",deleteOk);
            }];
        } DisposeBGErrorBlock:^(NSNumber *errorID) {
            NSLog(@"errorID:%@",errorID);
        }];
    }
}
#pragma BG5L  低功耗BG5
- (IBAction)startScanBG5LBotton:(id)sender {
    NSLog(@"开始扫描");
    [[ScanDeviceController commandGetInstance]commandScanDeviceType:HealthDeviceType_BG5L];
}
-(void)deviceBG5LDiscover:(NSNotification*)info {
    
    NSLog(@"Disover:%@",[info userInfo]);
    NSString *serialNub = [[info userInfo]valueForKey:@"SerialNumber"];
    self.tipTextView.text=[NSString stringWithFormat:@"扫描到设备：%@",serialNub];
    [discoverBG5LDevices addObject:serialNub];
    _tipTextView.text = [NSString stringWithFormat:@"%@\ndiscoverBG5LDevices:%@",_tipTextView.text,discoverBG5LDevices];
    
}
- (IBAction)startConnectBG5LBotton:(id)sender {
    
    NSLog(@"开始连接");
    if ([discoverBG5LDevices count]>0 ) {
        NSString *serialNub=[discoverBG5LDevices objectAtIndex:0];
        [[ConnectDeviceController commandGetInstance]commandContectDeviceWithDeviceType:HealthDeviceType_BG5L andSerialNub:serialNub];
    }
}
-(void)deviceBG5LConnectFailed:(NSNotification*)info {
    NSLog(@"连接失败:%@",[info userInfo]);
    [[ScanDeviceController commandGetInstance]commandScanDeviceType:HealthDeviceType_BG5L];
}

-(void)DeviceConnectForBG5L:(NSNotification *)tempNoti{
    BG5LController *bgController = [BG5LController shareIHBg5lController];
    NSArray *bgArray = [bgController getAllCurrentBG5LInstace];
    
    if(bgArray.count>0){
        BG5L *bgInstance = [bgArray objectAtIndex:0];
        
        NSDictionary *codeDic = [bgInstance codeStripStrAnalysis:CodeStr];
        NSNumber *yourBottle = [codeDic valueForKey:@"BottleID"];
        
        
        [bgInstance commandInitBGSetUnit:BGUnit_mmolPL BGUserID:YourUserName clientID:SDKKey clientSecret:SDKSecret Authentication:^(UserAuthenResult result) {
            if(result== UserAuthen_CombinedSuccess || result== UserAuthen_LoginSuccess || result== UserAuthen_RegisterSuccess || result== UserAuthen_TrySuccess){
                NSLog(@"verify success");
            }
            else{
                NSLog(@"Verify failed");
            }
        } DisposeBGBottleID:^(NSNumber *bottleID) {
            //same code
            if (bottleID.integerValue == yourBottle.integerValue) {
                //read code
                [bgInstance commandReadBGCodeDic:^(NSDictionary *codeDic) {
                    NSLog(@"codeDic:%@",codeDic);
                    [self commandBG5LSendCode:bgInstance];
                } DisposeBGErrorBlock:^(NSNumber *errorID) {
                    NSLog(@"errorID:%@",errorID);
                }];
            }
            //different code
            else{
                NSLog(@"codeDic:%@",codeDic);
                [self commandBG5LSendCode:bgInstance];
            }
        } DisposeBGErrorBlock:^(NSNumber *errorID) {
            NSLog(@"errorID:%@",errorID);
        }];
    }
}

-(void)DeviceDisConnectForBG5L:(NSNotification *)tempNoti{
    
    [[ScanDeviceController commandGetInstance]commandScanDeviceType:HealthDeviceType_BG5L];
}
-(void)commandBG5LSendCode:(BG5L *)bgInstance{
    NSDictionary *codeDic = [bgInstance codeStripStrAnalysis:CodeStr];
    NSNumber *yourBottle = [codeDic valueForKey:@"BottleID"];
    NSDate *yourValidDate = [codeDic valueForKey:@"DueDate"];
    NSNumber *yourRemainNub = [codeDic valueForKey:@"StripNum"];
    
    //send code
    [bgInstance commandSendBGCodeString:CodeStr bottleID:yourBottle validDate:yourValidDate remainNum:yourRemainNub DisposeBGSendCodeBlock:^(BOOL sendOk) {
        NSLog(@"send code success");
    } DisposeBGStartModel:^(BGOpenMode model) {
        NSLog(@"BGOpenMode:%d",model);
        //strip open mode
        if (model==BGOpenMode_Hand) {
            //start measure mode 0
            [bgInstance commandCreateBGtestModel:BGMeasureMode_Blood DisposeBGStripInBlock:^(BOOL stripIn) {
                NSLog(@"stripIn");
            } DisposeBGBloodBlock:^(BOOL blood) {
                NSLog(@"blood");
            } DisposeBGResultBlock:^(NSDictionary *result) {
                NSLog(@"result:%@",result);
            } DisposeBGTestModelBlock:^(BGMeasureMode model) {
                //0
                //1 blood mode
                NSLog(@"BGMeasureMode:%d",model);
            } DisposeBGErrorBlock:^(NSNumber *errorID) {
                NSLog(@"errorID:%@",errorID);
            }];
        }
        else{
            //start measure mode 1
            [bgInstance commandCreateBGtestStripInBlock:^(BOOL stripIn) {
                NSLog(@"stripIn");
            } DisposeBGBloodBlock:^(BOOL blood) {
                NSLog(@"blood");
            } DisposeBGResultBlock:^(NSDictionary *result) {
                NSLog(@"result:%@",result);
            } DisposeBGTestModelBlock:^(BGMeasureMode model) {
                //0
                //1 blood mode
                NSLog(@"BGMeasureMode:%d",model);
            } DisposeBGErrorBlock:^(NSNumber *errorID) {
                NSLog(@"errorID:%@",errorID);
            }];
        }
        
    } DisposeBGErrorBlock:^(NSNumber *errorID) {
        NSLog(@"errorID:%@",errorID);
    }];
    
}


- (IBAction)getBG5LMemory:(id)sender {
    BG5LController *bgController = [BG5LController shareIHBg5lController];
    NSArray *bgArray = [bgController getAllCurrentBG5LInstace];
    
    if(bgArray.count>0){
        BG5L *bgInstance = [bgArray objectAtIndex:0];
        [bgInstance commandTransferMemorryData:^(NSNumber *dataCount) {
            NSLog(@"dataCount:%@",dataCount);
        } DisposeBGHistoryData:^(NSDictionary *historyDataDic) {
            NSLog(@"historyDataDic:%@",historyDataDic);
            [bgInstance commandDeleteMemorryData:^(BOOL deleteOk) {
                NSLog(@"deleteOk:%d",deleteOk);
            }];
        } DisposeBGErrorBlock:^(NSNumber *errorID) {
            NSLog(@"errorID:%@",errorID);
        }];
    }
}

- (IBAction)GetBG5LEnergy:(id)sender {
    BG5LController *controller = [BG5LController shareIHBg5lController];
    NSArray *bg5lDeviceArray = [controller getAllCurrentBG5LInstace];
    if(bg5lDeviceArray.count){
        BG5L *bgInstance = [bg5lDeviceArray objectAtIndex:0];
        
        [bgInstance commandQueryBattery:^(NSNumber *energy) {
            
            _tipTextView.text = [NSString stringWithFormat:@"BG5L energyValue:%@",energy];
        } DisposeErrorBlock:^(NSNumber *errorID) {
            
        }];
        
    }
}


@end
