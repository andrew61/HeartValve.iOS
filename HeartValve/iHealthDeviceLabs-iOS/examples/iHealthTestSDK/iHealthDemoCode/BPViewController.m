//
//  BPViewController.m
//  iHealthDemoCode
//
//  Created by zhiwei jing on 14-9-23.
//  Copyright (c) 2014年 zhiwei jing. All rights reserved.
//

#import "BPViewController.h"
#import "BPHeader.h"
#import "HTSHeader.h"
#import "HealthHeader.h"
#import "ConnectDeviceController.h"
#import "ScanDeviceController.h"

#import "HSHeader.h"

@interface BPViewController ()

@end

@implementation BPViewController

@synthesize currentKD926UUIDStr;

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
    
    self.kd926OfflineDataBtn.hidden= YES;
    self.kd926EnergyBtn.hidden=YES;
    
    self.kd723OfflineDataBtn.hidden= YES;
    self.kd723EnergyBtn.hidden=YES;
    
    self.abpmSetTimeIntervalBtn.hidden=YES;
    self.abpmOfflineDataBtn.hidden= YES;
    self.abpmEnergyBtn.hidden=YES;
    
    discoverBP3LDevices=[[NSMutableArray alloc]init];
    discoverBP7SDevices=[[NSMutableArray alloc]init];
    discoverKD926Devices=[[NSMutableArray alloc]init];
    discoverKD723Devices=[[NSMutableArray alloc]init];
    discoverKN550BTDevices=[[NSMutableArray alloc]init];
    discoverABPMDevices=[[NSMutableArray alloc]init];
    discoverHTSDevices=[[NSMutableArray alloc]init];
    
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceConnectForBP3:) name:BP3ConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDisConnectForBP3:) name:BP3DisConnectNoti object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceConnectForBP5:) name:BP5ConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDisConnectForBP5:) name:BP5DisConnectNoti object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceConnectForBP7:) name:BP7ConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDisConnectForBP7:) name:BP7DisConnectNoti object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceConnectForBP3L:) name:BP3LConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDisConnectForBP3L:) name:BP3LDisConnectNoti object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceConnectForBP7S:) name:BP7SConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDisConnectForBP7S:) name:BP7SDisConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceConnectForKN550BT:) name:KN550BTConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDisConnectForKN550BT:) name:KN550BTDisConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceConnectForKD926:) name:KD926ConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDisConnectForKD926:) name:KD926DisConnectNoti object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceConnectForKD723:) name:KD723ConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDisConnectForKD723:) name:KD723DisConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceConnectForABPM:) name:ABPMConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDisConnectForABPM:) name:ABPMDisConnectNoti object:nil];
    
    //ABI Noti(Contains Arm and Leg)
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceConnectForABI:) name:ABIConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDisConnectForABI:) name:ABIDisConnectNoti object:nil];
    //ABI Noti(Contains Arm only)
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceConnectForArm:) name:ArmConnectNoti object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(DeviceDisConnectForArm:) name:ArmDisConnectNoti object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceBP3LDiscover:) name:BP3LDiscover object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceBP3LConnectFailed:) name:BP3LConnectFailed object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceBP7SDiscover:) name:BP7SDiscover object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceBP7SConnectFailed:) name:BP7SConnectFailed object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceKD926Discover:) name:KD926Discover object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceKD926ConnectFailed:) name:KD926ConnectFailed object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceKD723Discover:) name:KD723Discover object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceKD723ConnectFailed:) name:KD723ConnectFailed object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceABPMDiscover:) name:ABPMDiscover object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceABPMConnectFailed:) name:ABPMConnectFailed object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceKN550BTDiscover:) name:KN550BTDiscover object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceKN550BTConnectFailed:) name:KN550BTConnectFailed object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceHTSDiscover:) name:HTSDiscover object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceHTSConnectFailed:) name:HTSConnectFailed object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(HTSResultShow:) name:@"HTSResultShow" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(HTSBatteryLevelShow:) name:@"batteryLevelShow" object:nil];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(HTSBatteryLeve:) name:@"DeviceOpenSession" object:nil];
    
    [BP3Controller shareBP3Controller];
    
    [HTSController shareIHHTSController];
    
    [BP5Controller shareBP5Controller];
    [BP7Controller shareBP7Controller];
    [ABIController shareABIController];
    [BP3LController shareBP3LController];
    [BP7SController shareBP7SController];
    [KN550BTController shareKN550BTController];
    [KD926Controller shareKD926Controller];
    [KD723Controller shareKD723Controller];
    [ABPMController shareABPMController];
    
    [HS3Controller shareIHHs3Controller];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)HTSBatteryLeve:(NSNotification*)notic{
    
    NSArray*attay=[[HTSController shareIHHTSController] getAllCurrentHTSInstace];
    
    if (attay.count>0) {
        
        HTS*hts=[attay objectAtIndex:0];
        
        HealthUser*user=[[HealthUser alloc] init];;
        
        user.clientSecret=@"2407103b306943fcb33ef2863ae84988";
        
        user.clientID=@"e8776dc12c3d4a6796a722971b1cc0b4";
        
        user.userID=@"w@w.w";
        //HTS 获取温度数据
        [hts commandTestHTSWithUser:user Authentication:^(UserAuthenResult result) {
            
            
        } DisposeHTSResult:^(NSDictionary *resetDic) {
            _tipTextView.text=[NSString stringWithFormat:@"HTS Result:%@",resetDic];
            
        } DisposeErrorBlock:^(HTSDeviceError errorID) {
            
        }];
        //HTS要电量
        [hts commandGetBattary:^(NSNumber *battary) {
            _tipTextView.text=[NSString stringWithFormat:@"%@\nHTS Battery:%@",_tipTextView.text,battary];
        } DisposeErrorBlock:^(HTSDeviceError errorID) {
            
        }];
        
    }
    
}

-(void)HTSResultShow:(NSNotification *)notify
{
    NSDictionary *tempDic = notify.object;
    
    NSString *cTemperatureStr=[tempDic objectForKey:@"cTemperature"];
    NSString *fTemperatureStr=[tempDic objectForKey:@"fTemperature"];
    NSString *timeTextStr=[tempDic objectForKey:@"timeStamp"];
    NSString *typeTextStr=[tempDic objectForKey: @"measurePosition"];
    
    _tipTextView.text=[NSString stringWithFormat:@"Temperature: %@  %@\nTime: %@\nPosition: %@ \n%@",cTemperatureStr,fTemperatureStr,timeTextStr,typeTextStr,_tipTextView.text];
    
}

-(void)HTSBatteryLevelShow:(NSNotification *)notify
{
    NSDictionary *tempDic = notify.object;
    
    NSString *batteryLevelStr=[tempDic objectForKey:@"batteryLevelShow"];
    
    _tipTextView.text=[NSString stringWithFormat:@"Battery Level: %@\n %@",batteryLevelStr,_tipTextView.text];
    
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

#pragma mark - BP3
-(void)DeviceConnectForBP3:(NSNotification *)tempNoti{
    BP3Controller *controller = [BP3Controller shareBP3Controller];
    NSArray *bpDeviceArray = [controller getAllCurrentBP3Instace];
    if(bpDeviceArray.count){
        BP3 *bpInstance = [bpDeviceArray objectAtIndex:0];
        [bpInstance commandStartMeasureWithUser:YourUserName clientID:SDKKey clientSecret:SDKSecret Authentication:^(UserAuthenResult result) {
            NSLog(@"Authentication Result:%d",result);
            _tipTextView.text = [NSString stringWithFormat:@"Authentication Result:%d",result];
        } pressure:^(NSArray *pressureArr) {
            _tipTextView.text = [NSString stringWithFormat:@"pressureArr%@",pressureArr];
        } xiaoboWithHeart:^(NSArray *xiaoboArr) {
            
        } xiaoboNoHeart:^(NSArray *xiaoboArr) {
            
        } result:^(NSDictionary *dic) {
            NSLog(@"dic:%@",dic);
            _tipTextView.text = [NSString stringWithFormat:@"result:%@",dic];
        } errorBlock:^(BPDeviceError error) {
            NSLog(@"error:%d",error);
            _tipTextView.text = [NSString stringWithFormat:@"error:%d",error];
        }];
    }
    else{
        NSLog(@"log...");
        _tipTextView.text = [NSString stringWithFormat:@"date:%@",[NSDate date]];
    }
    
}

-(void)DeviceDisConnectForBP3:(NSNotification *)tempNoti{
    NSLog(@"info:%@",[tempNoti userInfo]);
}



#pragma mark - BP3L
-(void)DeviceConnectForBP3L:(NSNotification *)tempNoti{
    BP3LController *controller = [BP3LController shareBP3LController];
    NSArray *bpDeviceArray = [controller getAllCurrentBP3LInstace];
    if(bpDeviceArray.count){
        BP3L *bpInstance = [bpDeviceArray objectAtIndex:0];
        //@"jing@30.com"
        [bpInstance commandStartMeasureWithUser:YourUserName clientID:SDKKey clientSecret:SDKSecret Authentication:^(UserAuthenResult result) {
            NSLog(@"Authentication Result:%d",result);
            _tipTextView.text = [NSString stringWithFormat:@"Authentication Result:%d",result];
        } pressure:^(NSArray *pressureArr) {
            _tipTextView.text = [NSString stringWithFormat:@"pressureArr%@",pressureArr];
        } xiaoboWithHeart:^(NSArray *xiaoboArr) {
            
        } xiaoboNoHeart:^(NSArray *xiaoboArr) {
            
        } result:^(NSDictionary *dic) {
            NSLog(@"dic:%@",dic);
            _tipTextView.text = [NSString stringWithFormat:@"result:%@",dic];
        } errorBlock:^(BPDeviceError error) {
            NSLog(@"error:%d",error);
            _tipTextView.text = [NSString stringWithFormat:@"error:%d",error];
        }];
    }
    else{
        NSLog(@"log...");
        _tipTextView.text = [NSString stringWithFormat:@"date:%@",[NSDate date]];
    }
    
}

-(void)DeviceDisConnectForBP3L:(NSNotification *)tempNoti{
    NSLog(@"info:%@",[tempNoti userInfo]);
}


#pragma mark - BP5
-(void)DeviceConnectForBP5:(NSNotification *)tempNoti{
    BP5Controller *controller = [BP5Controller shareBP5Controller];
    NSArray *bpDeviceArray = [controller getAllCurrentBP5Instace];
    if(bpDeviceArray.count){
        BP5 *bpInstance = [bpDeviceArray objectAtIndex:0];
        //@"jing@30.com"
        [bpInstance commandStartMeasureWithUser:YourUserName clientID:SDKKey clientSecret:SDKSecret Authentication:^(UserAuthenResult result) {
            NSLog(@"Authentication Result:%d",result);
            _tipTextView.text = [NSString stringWithFormat:@"Authentication Result:%d",result];
        } pressure:^(NSArray *pressureArr) {
            _tipTextView.text = [NSString stringWithFormat:@"pressureArr%@",pressureArr];
        } xiaoboWithHeart:^(NSArray *xiaoboArr) {
            
        } xiaoboNoHeart:^(NSArray *xiaoboArr) {
            
        } result:^(NSDictionary *dic) {
            NSLog(@"dic:%@",dic);
            _tipTextView.text = [NSString stringWithFormat:@"result:%@",dic];
        } errorBlock:^(BPDeviceError error) {
            NSLog(@"error:%d",error);
            _tipTextView.text = [NSString stringWithFormat:@"error:%d",error];
        }];
    }
    else{
        NSLog(@"log...");
        _tipTextView.text = [NSString stringWithFormat:@"date:%@",[NSDate date]];
    }
    
}

-(void)DeviceDisConnectForBP5:(NSNotification *)tempNoti{
    NSLog(@"info:%@",[tempNoti userInfo]);
}

#pragma mark - BP7
-(void)DeviceConnectForBP7:(NSNotification *)tempNoti{
    BP7Controller *controller = [BP7Controller shareBP7Controller];
    NSArray *bpDeviceArray = [controller getAllCurrentBP7Instace];
    if(bpDeviceArray.count){
        BP7 *bpInstance = [bpDeviceArray objectAtIndex:0];
        [bpInstance commandStartGetAngleWithUser:YourUserName clientID:SDKKey clientSecret:SDKSecret Authentication:^(UserAuthenResult result) {
            _tipTextView.text = [NSString stringWithFormat:@"Authentication Result:%d",result];
            NSLog(@"Authentication Result:%d",result);
        } angle:^(NSDictionary *dic) {
            NSLog(@"angle:%@",dic);
            _tipTextView.text = [NSString stringWithFormat:@"angle:%@",dic];
            NSNumber *angleDigital = [dic valueForKey:@"angle"];
            if(angleDigital.intValue>10 && angleDigital.intValue<30){
                [bpInstance commandStartMeasure:^(NSArray *pressureArr) {
                    
                } xiaoboWithHeart:^(NSArray *xiaoboArr) {
                    
                } xiaoboNoHeart:^(NSArray *xiaoboArr) {
                    
                } result:^(NSDictionary *dic) {
                    _tipTextView.text = [NSString stringWithFormat:@"result:%@",dic];
                    NSLog(@"dic:%@",dic);
                } errorBlock:^(BPDeviceError error) {
                    NSLog(@"error:%d",error);
                    _tipTextView.text = [NSString stringWithFormat:@"error:%d",error];
                }];
            }
        } errorBlock:^(BPDeviceError error) {
            NSLog(@"error:%d",error);
        }];
    }
    else{
        NSLog(@"log...");
        _tipTextView.text = [NSString stringWithFormat:@"date:%@",[NSDate date]];
    }
    
}

-(void)DeviceDisConnectForBP7:(NSNotification *)tempNoti{
    NSLog(@"info:%@",[tempNoti userInfo]);
}

#pragma mark - BP7S
-(void)DeviceConnectForBP7S:(NSNotification *)tempNoti{
    BP7SController *controller = [BP7SController shareBP7SController];
    NSArray *bpDeviceArray = [controller getAllCurrentBP7SInstace];
    if(bpDeviceArray.count){
        BP7S *bpInstance = [bpDeviceArray objectAtIndex:0];
        
        [bpInstance commandFounction:^(NSDictionary *dic) {
            
            [bpInstance commandTransferMemoryDataWithUser:YourUserName clientID:SDKKey clientSecret:SDKSecret Authentication:^(UserAuthenResult result) {
                _tipTextView.text = [NSString stringWithFormat:@"Authentication Result:%d",result];
                NSLog(@"Authentication Result:%d",result);
            }totalCount:^(NSNumber *num){
                NSLog(@"上传总条数；%@",num);
                _tipTextView.text = [NSString stringWithFormat:@"%@\n历史数量为:%@ ",_tipTextView.text,num];
            } pregress:^(NSNumber *progress){
                _tipTextView.text = [NSString stringWithFormat:@"%@\n进度为:%@ ",_tipTextView.text,progress];
                NSLog(@"上传进度为：%@",progress);
            } dataArray:^(NSArray *array){
                
                _tipTextView.text = [NSString stringWithFormat:@"%@\n历史记录:%@ ",_tipTextView.text,array];
                NSLog(@"历史记录为：%@",array);
            } errorBlock:^(BPDeviceError error) {
                NSLog(@"error:%d",error);
            }];
            
        } errorBlock:^(BPDeviceError error) {
            
        }];
        
        
    }
    else{
        NSLog(@"log...");
        _tipTextView.text = [NSString stringWithFormat:@"date:%@",[NSDate date]];
    }
    
}

-(void)DeviceDisConnectForBP7S:(NSNotification *)tempNoti{
    NSLog(@"info:%@",[tempNoti userInfo]);
}

#pragma mark - KN550BT
-(void)DeviceConnectForKN550BT:(NSNotification *)tempNoti{
    KN550BTController *controller = [KN550BTController shareKN550BTController];
    NSArray *bpDeviceArray = [controller getAllCurrentKN550BTInstace];
    if(bpDeviceArray.count){
        KN550BT *bpInstance = [bpDeviceArray objectAtIndex:0];
        
        [bpInstance commandFounction:^(NSDictionary *dic) {
            
            [bpInstance commandTransferMemoryDataWithUser:YourUserName clientID:SDKKey clientSecret:SDKSecret Authentication:^(UserAuthenResult result) {
                _tipTextView.text = [NSString stringWithFormat:@"Authentication Result:%d",result];
                NSLog(@"Authentication Result:%d",result);
            }totalCount:^(NSNumber *num){
                NSLog(@"上传总条数；%@",num);
                _tipTextView.text = [NSString stringWithFormat:@"%@\n历史数量为:%@ ",_tipTextView.text,num];
            } pregress:^(NSNumber *progress){
                _tipTextView.text = [NSString stringWithFormat:@"%@\n进度为:%@ ",_tipTextView.text,progress];
                NSLog(@"上传进度为：%@",progress);
            } dataArray:^(NSArray *array){
                
                _tipTextView.text = [NSString stringWithFormat:@"%@\n历史记录:%@ ",_tipTextView.text,array];
                NSLog(@"历史记录为：%@",array);
            } errorBlock:^(BPDeviceError error) {
                NSLog(@"error:%d",error);
            }];
        } errorBlock:^(BPDeviceError error) {
            
        }];
        
    }
    else{
        NSLog(@"log...");
        _tipTextView.text = [NSString stringWithFormat:@"date:%@",[NSDate date]];
    }
    
}

-(void)DeviceDisConnectForKN550BT:(NSNotification *)tempNoti{
    NSLog(@"info:%@",[tempNoti userInfo]);
    
    
}

#pragma mark - KD926
-(void)DeviceConnectForKD926:(NSNotification *)tempNoti{
    
    NSDictionary *infoDic = [tempNoti userInfo];
    self.currentKD926UUIDStr = [infoDic objectForKey:@"ID"];
    
    self.kd926EnergyBtn.hidden=NO;
    self.kd926OfflineDataBtn.hidden=NO;
}

-(void)DeviceDisConnectForKD926:(NSNotification *)tempNoti{
    NSLog(@"info:%@",[tempNoti userInfo]);
    NSDictionary *infoDic = [tempNoti userInfo];
    NSString *uuidString = [infoDic objectForKey:@"ID"];
    if([self.currentKD926UUIDStr isEqualToString:uuidString]){
        self.kd926OfflineDataBtn.hidden= YES;
        self.kd926EnergyBtn.hidden=YES;
        [[ScanDeviceController commandGetInstance]commandScanDeviceType:HealthDeviceType_KD926];
    }
    
}
- (IBAction)KD926GetOfflinData:(id)sender {
    
    KD926Controller *controller = [KD926Controller shareKD926Controller];
    NSArray *bpDeviceArray = [controller getAllCurrentKD926Instace];
    if(bpDeviceArray.count){
        KD926 *bpInstance = [bpDeviceArray objectAtIndex:0];
        [bpInstance commandFounction:^(NSDictionary *dic) {
            NSLog(@"功能字典为：%@",dic);
            [bpInstance commandTransferMemorytotalCount:^(NSNumber *num) {
                NSLog(@"只要数量的上传总条数为：%@",num);
                if(num.integerValue==0)
                {
                    //发送离线记忆传输完成指令
                    [bpInstance commandBatchUploadFinish];
                }
                else
                {
                    [bpInstance commandTransferMemoryDataWithUser:YourUserName clientID:SDKKey clientSecret:SDKSecret Authentication:^(UserAuthenResult result) {
                        _tipTextView.text = [NSString stringWithFormat:@"Authentication Result:%d",result];
                        NSLog(@"Authentication Result:%d",result);
                    }withGroupNumber:[NSNumber numberWithInteger:0x01]  totalCount:^(NSNumber *num){
                        NSLog(@"上传总条数；%@",num);
                        _tipTextView.text = [NSString stringWithFormat:@"%@\n历史数量为:%@ ",_tipTextView.text,num];
                    } pregress:^(NSNumber *progress){
                        _tipTextView.text = [NSString stringWithFormat:@"%@\n进度为:%@ ",_tipTextView.text,progress];
                        if (progress.integerValue==1) {
                            
                        }
                        NSLog(@"上传进度为：%@",progress);
                    } dataArray:^(NSArray *array){
                        _tipTextView.text = [NSString stringWithFormat:@"%@\n历史记录:%@ ",_tipTextView.text,array];
                        NSLog(@"历史记录为：%@",array);
                        //发送离线记忆传输完成指令
                        [bpInstance commandBatchUploadFinish];
                    } errorBlock:^(BPDeviceError error) {
                        NSLog(@"error:%d",error);
                    }];
                    
                }
                
            } withGroupNumber:[NSNumber numberWithInteger:0x01] errorBlock:^(BPDeviceError error) {
                
            }];
            
            
        } errorBlock:^(BPDeviceError error) {
            
        }];
        
        
        
        
    }
    else{
        NSLog(@"log...");
        _tipTextView.text = [NSString stringWithFormat:@"date:%@",[NSDate date]];
    }
    
    
}
- (IBAction)KD926GetEnergy:(id)sender {
    KD926Controller *controller = [KD926Controller shareKD926Controller];
    NSArray *bpDeviceArray = [controller getAllCurrentKD926Instace];
    if(bpDeviceArray.count){
        KD926 *bpInstance = [bpDeviceArray objectAtIndex:0];
        
        [bpInstance commandEnergy:^(NSNumber *energyValue) {
            _tipTextView.text = [NSString stringWithFormat:@"energyValue:%@",energyValue];
        } errorBlock:^(BPDeviceError error) {
            
        }];
    }
}
#pragma mark - KD723
-(void)DeviceConnectForKD723:(NSNotification *)tempNoti{
    
    NSDictionary *infoDic = [tempNoti userInfo];
    self.currentKD723UUIDStr = [infoDic objectForKey:@"ID"];
    
    self.kd723EnergyBtn.hidden=NO;
    self.kd723OfflineDataBtn.hidden=NO;
}

-(void)DeviceDisConnectForKD723:(NSNotification *)tempNoti{
    NSLog(@"info:%@",[tempNoti userInfo]);
    NSDictionary *infoDic = [tempNoti userInfo];
    NSString *uuidString = [infoDic objectForKey:@"ID"];
    if([self.currentKD723UUIDStr isEqualToString:uuidString]){
        self.kd723OfflineDataBtn.hidden= YES;
        self.kd723EnergyBtn.hidden=YES;
        [[ScanDeviceController commandGetInstance]commandScanDeviceType:HealthDeviceType_KD723];
    }
    
}
- (IBAction)KD723GetOfflinData:(id)sender {
    
    KD723Controller *controller = [KD723Controller shareKD723Controller];
    NSArray *bpDeviceArray = [controller getAllCurrentKD723Instace];
    if(bpDeviceArray.count){
        KD723 *bpInstance = [bpDeviceArray objectAtIndex:0];
        [bpInstance commandFounction:^(NSDictionary *dic) {
            NSLog(@"KD-723功能字典为：%@",dic);
            [bpInstance commandTransferMemorytotalCount:^(NSNumber *num) {
                NSLog(@"KD-723 只要数量的上传总条数为：%@",num);
                if(num.integerValue==0)
                {
                    //发送离线记忆传输完成指令
                    [bpInstance commandBatchUploadFinish];
                }
                else
                {
                    [bpInstance commandTransferMemoryDataWithUser:YourUserName clientID:SDKKey clientSecret:SDKSecret Authentication:^(UserAuthenResult result) {
                        _tipTextView.text = [NSString stringWithFormat:@"KD-723 Authentication Result:%d",result];
                        NSLog(@"KD-723 Authentication Result:%d",result);
                    }withGroupNumber:[NSNumber numberWithInteger:0x02]  totalCount:^(NSNumber *num){
                        NSLog(@"KD-723 上传总条数；%@",num);
                        if(num==0)
                        {
                            //发送离线记忆传输完成指令
                            [bpInstance commandBatchUploadFinish];
                        }
                        _tipTextView.text = [NSString stringWithFormat:@"%@\n历史数量为:%@ ",_tipTextView.text,num];
                    } pregress:^(NSNumber *progress){
                        _tipTextView.text = [NSString stringWithFormat:@"%@\n进度为:%@ ",_tipTextView.text,progress];
                        if (progress.integerValue==1) {
                            
                        }
                        NSLog(@"KD-723 上传进度为：%@",progress);
                    } dataArray:^(NSArray *array){
                        _tipTextView.text = [NSString stringWithFormat:@"%@\n历史记录:%@ ",_tipTextView.text,array];
                        NSLog(@"KD-723 历史记录为：%@",array);
                        //发送离线记忆传输完成指令
                        [bpInstance commandBatchUploadFinish];
                    } errorBlock:^(BPDeviceError error) {
                        NSLog(@"error:%d",error);
                    }];
                    
                    
                }
                
            } withGroupNumber:[NSNumber numberWithInteger:0x02] errorBlock:^(BPDeviceError error) {
                
            }];
            
            
        } errorBlock:^(BPDeviceError error) {
            
        }];
        
        
        
        
    }
    else{
        NSLog(@"log...");
        _tipTextView.text = [NSString stringWithFormat:@"date:%@",[NSDate date]];
    }
    
    
}
- (IBAction)KD723GetEnergy:(id)sender {
    KD723Controller *controller = [KD723Controller shareKD723Controller];
    NSArray *bpDeviceArray = [controller getAllCurrentKD723Instace];
    if(bpDeviceArray.count){
        KD723 *bpInstance = [bpDeviceArray objectAtIndex:0];
        
        [bpInstance commandEnergy:^(NSNumber *energyValue) {
            _tipTextView.text = [NSString stringWithFormat:@"KD-723 energyValue:%@",energyValue];
        } errorBlock:^(BPDeviceError error) {
            
        }];
    }
}

#pragma mark - ABPM
-(void)DeviceConnectForABPM:(NSNotification *)tempNoti{
    
    NSDictionary *infoDic = [tempNoti userInfo];
    self.currentABPMUUIDStr = [infoDic objectForKey:@"ID"];
    
    self.abpmSetTimeIntervalBtn.hidden=NO;
    self.abpmEnergyBtn.hidden=NO;
    self.abpmOfflineDataBtn.hidden=NO;
}

-(void)DeviceDisConnectForABPM:(NSNotification *)tempNoti{
    NSLog(@"info:%@",[tempNoti userInfo]);
    NSDictionary *infoDic = [tempNoti userInfo];
    NSString *uuidString = [infoDic objectForKey:@"ID"];
    if([self.currentABPMUUIDStr isEqualToString:uuidString]){
        self.abpmSetTimeIntervalBtn.hidden=YES;
        self.abpmOfflineDataBtn.hidden= YES;
        self.abpmEnergyBtn.hidden=YES;
        [[ScanDeviceController commandGetInstance]commandScanDeviceType:HealthDeviceType_ABPM];
    }
    
}
- (IBAction)ABPMGetOfflinData:(id)sender {
    
    ABPMController *controller = [ABPMController shareABPMController];
    NSArray *bpDeviceArray = [controller getAllCurrentABPMInstace];
    if(bpDeviceArray.count){
        ABPM *bpInstance = [bpDeviceArray objectAtIndex:0];
        [bpInstance commandFounction:^(NSDictionary *dic) {
            NSLog(@"ABPM功能字典为：%@",dic);
            [bpInstance commandTransferMemorytotalCount:^(NSNumber *num) {
                NSLog(@"ABPM 只要数量的上传总条数为：%@",num);
                if(num.integerValue==0)
                {
                    //发送离线记忆传输完成指令
                }
                else
                {
                    
                    [bpInstance commandTransferMemoryDataWithUser:YourUserName clientID:SDKKey clientSecret:SDKSecret Authentication:^(UserAuthenResult result) {
                        _tipTextView.text = [NSString stringWithFormat:@"ABPM Authentication Result:%d",result];
                        NSLog(@"ABPM Authentication Result:%d",result);
                    }totalCount:^(NSNumber *num){
                        NSLog(@"ABPM 上传总条数；%@",num);
                        if(num==0)
                        {
                            //发送离线记忆传输完成指令
                        }
                        _tipTextView.text = [NSString stringWithFormat:@"%@\n历史数量为:%@ ",_tipTextView.text,num];
                    } pregress:^(NSNumber *progress){
                        _tipTextView.text = [NSString stringWithFormat:@"%@\n进度为:%@ ",_tipTextView.text,progress];
                        if (progress.integerValue==1) {
                            
                        }
                        NSLog(@"ABPM 上传进度为：%@",progress);
                    } dataArray:^(NSArray *array){
                        _tipTextView.text = [NSString stringWithFormat:@"%@\n历史记录:%@ ",_tipTextView.text,array];
                        NSLog(@"ABPM 历史记录为：%@",array);
                        //发送离线记忆传输完成指令
                        
                    } finish:^(BOOL finishFlag) {
                        
                    }errorBlock:^(BPDeviceError error) {
                        NSLog(@"error:%d",error);
                    }];
                    
                    
                }
                
            } errorBlock:^(BPDeviceError error) {
                
            }];
            
            
        } errorBlock:^(BPDeviceError error) {
            
        }];
        
        
    }
    else{
        NSLog(@"log...");
        _tipTextView.text = [NSString stringWithFormat:@"date:%@",[NSDate date]];
    }
    
    
}
- (IBAction)ABPMGetEnergy:(id)sender {
    ABPMController *controller = [ABPMController shareABPMController];
    NSArray *bpDeviceArray = [controller getAllCurrentABPMInstace];
    if(bpDeviceArray.count){
        ABPM *bpInstance = [bpDeviceArray objectAtIndex:0];
        
        [bpInstance commandEnergy:^(NSNumber *energyValue) {
            _tipTextView.text = [NSString stringWithFormat:@"ABPM energyValue:%@",energyValue];
        } errorBlock:^(BPDeviceError error) {
            
        }];
    }
}
- (IBAction)ABPMSetTimeInterval:(id)sender {
    ABPMController *controller = [ABPMController shareABPMController];
    NSArray *bpDeviceArray = [controller getAllCurrentABPMInstace];
    if(bpDeviceArray.count){
        ABPM *bpInstance = [bpDeviceArray objectAtIndex:0];
        [bpInstance commandSetAutoMeasureTimeWithSleepTimeSection: [NSArray arrayWithObjects:@11,@12,@13,@14,@15,@16,nil]napTimeSection:[NSArray arrayWithObjects:@11,@12,@13,@14,@15,@16,nil] totalTime:@99 result:^(NSDictionary *setResult) {
            NSLog(@"ABPM setResult:%@",setResult);
            _tipTextView.text = [NSString stringWithFormat:@"ABPM setResult:%@",setResult];
        } errorBlock:^(BPDeviceError error) {
            
        }];
    }
}

#pragma mark - ABI
-(void)DeviceConnectForABI:(NSNotification *)tempNoti{
    ABI *abiInstance = [[ABIController shareABIController]getCurrentABIInstace];
    //Detect CurrentABIInstace
    if (abiInstance != nil) {
        
        //        [abiInstance commandQueryEnergy:^(NSNumber *energyValue) {
        //            NSLog(@"energyValue:%d",energyValue.integerValue);
        //        } leg:^(NSNumber *energyValue) {
        //            NSLog(@"energyValue:%d",energyValue.integerValue);
        //        } errorBlock:^(BPDeviceError error) {
        //
        //        }];
        //
        //        return;
        
        [abiInstance commandStartMeasureWithUser:YourUserName clientID:SDKKey clientSecret:SDKSecret Authentication:^(UserAuthenResult result) {
            _tipTextView.text = [NSString stringWithFormat:@"Authentication Result:%d",result];
            NSLog(@"Authentication Result:%d",result);
        } armPressure:^(NSArray *pressureArr) {
            NSLog(@"armPressure:%@",pressureArr);
        } legPressure:^(NSArray *pressureArr) {
            NSLog(@"legPressure:%@",pressureArr);
        } armXiaoboWithHeart:^(NSArray *xiaoboArr) {
            NSLog(@"armXiaoboWithHeart:%@",xiaoboArr);
        } legXiaoboWithHeart:^(NSArray *xiaoboArr) {
            NSLog(@"legXiaoboWithHeart:%@",xiaoboArr);
        } armXiaoboNoHeart:^(NSArray *xiaoboArr) {
            NSLog(@"armXiaoboNoHeart:%@",xiaoboArr);
        } legXiaoboNoHeart:^(NSArray *xiaoboArr) {
            NSLog(@"legXiaoboNoHeart:%@",xiaoboArr);
        } armResult:^(NSDictionary *dic) {
            _tipTextView.text = [NSString stringWithFormat:@"armResult:%@",dic];
            NSLog(@"armResult:%@",dic);
        } legResult:^(NSDictionary *dic) {
            _tipTextView.text = [NSString stringWithFormat:@"legResult:%@",dic];
            NSLog(@"legResult:%@",dic);
        } errorBlock:^(BPDeviceError error) {
            
        }];
    }
    
}

-(void)DeviceDisConnectForABI:(NSNotification *)tempNoti{
    NSLog(@"DeviceDisConnectForABI:%@",[tempNoti userInfo]);
}

#pragma mark - Arm
-(void)DeviceConnectForArm:(NSNotification *)tempNoti{
    ABI *abiInstance = [[ABIController shareABIController]getCurrentArmInstance];
    //Detect CurrentArmInstance
    if (abiInstance != nil) {
        //query battery if need
        //        [abiInstance commandQueryEnergy:^(NSNumber *energyValue) {
        //            NSLog(@"energyValue:%d",energyValue.integerValue);
        //        } errorBlock:^(BPDeviceError error) {
        //            NSLog(@"BPDeviceError%d",error);
        //        }];
        [abiInstance commandStartMeasureWithUser:YourUserName clientID:SDKKey clientSecret:SDKSecret Authentication:^(UserAuthenResult result) {
            _tipTextView.text = [NSString stringWithFormat:@"Authentication Result:%d",result];
            NSLog(@"Authentication Result:%d",result);
            //Stop ArmMeasure if need
            //            [self performSelector:@selector(stopArmMeasure) withObject:nil afterDelay:10];
        } armPressure:^(NSArray *pressureArr) {
            NSLog(@"armPressure:%@",pressureArr);
        } armXiaoboWithHeart:^(NSArray *xiaoboArr) {
            NSLog(@"armXiaoboWithHeart:%@",xiaoboArr);
        } armXiaoboNoHeart:^(NSArray *xiaoboArr) {
            NSLog(@"armXiaoboNoHeart:%@",xiaoboArr);
        } armResult:^(NSDictionary *dic) {
            _tipTextView.text = [NSString stringWithFormat:@"armResult:%@",dic];
            NSLog(@"armResult:%@",dic);
        } errorBlock:^(BPDeviceError error) {
            NSLog(@"BPDeviceError:%d",error);
        }];
    }
}

-(void)stopArmMeasure{
    ABI *abiInstance = [[ABIController shareABIController]getCurrentArmInstance];
    //Detect CurrentArmInstance
    if (abiInstance != nil) {
        [abiInstance stopABIArmMeassureBlock:^(BOOL result) {
            NSLog(@"stopABIArmMeassureBlock:%d",result);
        } errorBlock:^(BPDeviceError error) {
            NSLog(@"BPDeviceError:%d",error);
        }];
    }
}
-(void)DeviceDisConnectForArm:(NSNotification *)tempNoti{
    
    NSLog(@"DeviceDisConnectForArm:%@",[tempNoti userInfo]);
}

- (IBAction)BPStartMeasure:(UIButton *)sender {
    
    BP3LController *controller = [BP3LController shareBP3LController];
    NSArray *bpDeviceArray = [controller getAllCurrentBP3LInstace];
    if(bpDeviceArray.count){
        BP3L *bpInstance = [bpDeviceArray objectAtIndex:0];
        //@"jing@30.com"
        [bpInstance commandStartMeasureWithUser:YourUserName clientID:SDKKey clientSecret:SDKSecret Authentication:^(UserAuthenResult result) {
            NSLog(@"Authentication Result:%d",result);
            _tipTextView.text = [NSString stringWithFormat:@"Authentication Result:%d",result];
        } pressure:^(NSArray *pressureArr) {
            _tipTextView.text = [NSString stringWithFormat:@"pressureArr%@",pressureArr];
        } xiaoboWithHeart:^(NSArray *xiaoboArr) {
            
        } xiaoboNoHeart:^(NSArray *xiaoboArr) {
            
        } result:^(NSDictionary *dic) {
            NSLog(@"dic:%@",dic);
            _tipTextView.text = [NSString stringWithFormat:@"result:%@",dic];
        } errorBlock:^(BPDeviceError error) {
            NSLog(@"error:%d",error);
            _tipTextView.text = [NSString stringWithFormat:@"error:%d",error];
        }];
    }
}
- (IBAction)startScanBP3LBotton:(id)sender {
    NSLog(@"开始扫描");
    [[ScanDeviceController commandGetInstance]commandScanDeviceType:HealthDeviceType_BP3L];
}
- (IBAction)startConnectBP3LBotton:(id)sender {
    
    NSLog(@"开始连接");
    if ([discoverBP3LDevices count]>0 ) {
        NSString *serialNub=[discoverBP3LDevices objectAtIndex:0];
        [[ConnectDeviceController commandGetInstance]commandContectDeviceWithDeviceType:HealthDeviceType_BP3L andSerialNub:serialNub];
    }
}
- (IBAction)startScanBP7SBotton:(id)sender {
    NSLog(@"开始扫描");
    [[ScanDeviceController commandGetInstance]commandScanDeviceType:HealthDeviceType_BP7S];
}
- (IBAction)startConnectBP7SBotton:(id)sender {
    
    NSLog(@"开始连接");
    if ([discoverBP7SDevices count]>0 ) {
        NSString *serialNub=[discoverBP7SDevices objectAtIndex:0];
        [[ConnectDeviceController commandGetInstance]commandContectDeviceWithDeviceType:HealthDeviceType_BP7S andSerialNub:serialNub];
    }
}
- (IBAction)startScanKD926Botton:(id)sender {
    NSLog(@"开始扫描");
    [[ScanDeviceController commandGetInstance]commandScanDeviceType:HealthDeviceType_KD926];
}
- (IBAction)startConnectKD926Botton:(id)sender {
    
    NSLog(@"开始连接");
    if ([discoverKD926Devices count]>0 ) {
        NSString *serialNub=[discoverKD926Devices objectAtIndex:0];
        [[ConnectDeviceController commandGetInstance]commandContectDeviceWithDeviceType:HealthDeviceType_KD926 andSerialNub:serialNub];
    }
}

- (IBAction)startScanKD723Botton:(id)sender {
    NSLog(@"开始扫描");
    [[ScanDeviceController commandGetInstance]commandScanDeviceType:HealthDeviceType_KD723];
}
- (IBAction)startConnectKD723Botton:(id)sender {
    
    NSLog(@"开始连接");
    if ([discoverKD723Devices count]>0 ) {
        NSString *serialNub=[discoverKD723Devices objectAtIndex:0];
        [[ConnectDeviceController commandGetInstance]commandContectDeviceWithDeviceType:HealthDeviceType_KD723 andSerialNub:serialNub];
    }
}
- (IBAction)startScanABPMBotton:(id)sender {
    NSLog(@"开始扫描");
    [[ScanDeviceController commandGetInstance]commandScanDeviceType:HealthDeviceType_ABPM];
}
- (IBAction)startConnectABPMBotton:(id)sender {
    
    NSLog(@"开始连接");
    if ([discoverABPMDevices count]>0 ) {
        NSString *serialNub=[discoverABPMDevices objectAtIndex:0];
        [[ConnectDeviceController commandGetInstance]commandContectDeviceWithDeviceType:HealthDeviceType_ABPM andSerialNub:serialNub];
    }
}

- (IBAction)startScanKN550BTBotton:(id)sender {
    NSLog(@"开始扫描");
    [[ScanDeviceController commandGetInstance]commandScanDeviceType:HealthDeviceType_KN550BT];
}
- (IBAction)startConnectKN550BTBotton:(id)sender {
    
    NSLog(@"开始连接");
    if ([discoverKN550BTDevices count]>0 ) {
        NSString *serialNub=[discoverKN550BTDevices objectAtIndex:0];
        [[ConnectDeviceController commandGetInstance]commandContectDeviceWithDeviceType:HealthDeviceType_KN550BT andSerialNub:serialNub];
    }
}
- (IBAction)startScanHTSBotton:(id)sender {
    NSLog(@"开始扫描");
    [[ScanDeviceController commandGetInstance]commandScanDeviceType:HealthDeviceType_HTS];
}
- (IBAction)startConnectHTSBotton:(id)sender {
    
    NSLog(@"开始连接");
    if ([discoverHTSDevices count]>0 ) {
        NSString *serialNub=[discoverHTSDevices objectAtIndex:0];
        [[ConnectDeviceController commandGetInstance]commandContectDeviceWithDeviceType:HealthDeviceType_HTS andSerialNub:serialNub];
    }
}

-(void)deviceBP3LDiscover:(NSNotification*)info {
    
    NSLog(@"Disover:%@",[info userInfo]);
    NSString *serialNub = [[info userInfo]valueForKey:@"SerialNumber"];
    self.tipTextView.text=[NSString stringWithFormat:@"扫描到设备：%@",serialNub];
    [discoverBP3LDevices addObject:serialNub];
    _tipTextView.text = [NSString stringWithFormat:@"%@\ndiscoverBP3LDevices:%@",_tipTextView.text,discoverBP3LDevices];
    
}
-(void)deviceBP7SDiscover:(NSNotification*)info {
    
    NSLog(@"Disover:%@",[info userInfo]);
    NSString *serialNub = [[info userInfo]valueForKey:@"SerialNumber"];
    self.tipTextView.text=[NSString stringWithFormat:@"扫描到设备：%@",serialNub];
    if(serialNub==nil)
    {
        serialNub = [[info userInfo]valueForKey:@"ID"];
    }
    [discoverBP7SDevices addObject:serialNub];
    _tipTextView.text = [NSString stringWithFormat:@"%@\ndiscoverBP7SDevices:%@",_tipTextView.text,discoverBP7SDevices];
    
}
-(void)deviceKN550BTDiscover:(NSNotification*)info {
    
    NSLog(@"Disover:%@",[info userInfo]);
    NSString *serialNub = [[info userInfo]valueForKey:@"SerialNumber"];
    if(serialNub==nil)
    {
        serialNub = [[info userInfo]valueForKey:@"ID"];
    }
    self.tipTextView.text=[NSString stringWithFormat:@"扫描到设备：%@",serialNub];
    [discoverKN550BTDevices addObject:serialNub];
    _tipTextView.text = [NSString stringWithFormat:@"%@\ndiscoverKN550BTDevices:%@",_tipTextView.text,discoverKN550BTDevices];
}
-(void)deviceKD926Discover:(NSNotification*)info {
    
    NSLog(@"Disover:%@",[info userInfo]);
    NSString *serialNub = [[info userInfo]valueForKey:@"SerialNumber"];
    if(serialNub==nil)
    {
        serialNub = [[info userInfo]valueForKey:@"ID"];
    }
    self.tipTextView.text=[NSString stringWithFormat:@"扫描到设备：%@",serialNub];
    [discoverKD926Devices addObject:serialNub];
    _tipTextView.text = [NSString stringWithFormat:@"%@\ndiscoverKD926Devices:%@",_tipTextView.text,discoverKD926Devices];
    
}
-(void)deviceKD723Discover:(NSNotification*)info {
    
    NSLog(@"Disover:%@",[info userInfo]);
    NSString *serialNub = [[info userInfo]valueForKey:@"SerialNumber"];
    if(serialNub==nil)
    {
        serialNub = [[info userInfo]valueForKey:@"ID"];
    }
    self.tipTextView.text=[NSString stringWithFormat:@"扫描到设备：%@",serialNub];
    [discoverKD723Devices addObject:serialNub];
    _tipTextView.text = [NSString stringWithFormat:@"%@\ndiscoverKD723Devices:%@",_tipTextView.text,discoverKD723Devices];
    
}
-(void)deviceABPMDiscover:(NSNotification*)info {
    
    NSLog(@"Disover:%@",[info userInfo]);
    NSString *serialNub = [[info userInfo]valueForKey:@"SerialNumber"];
    if(serialNub==nil)
    {
        serialNub = [[info userInfo]valueForKey:@"ID"];
    }
    self.tipTextView.text=[NSString stringWithFormat:@"扫描到设备：%@",serialNub];
    [discoverABPMDevices addObject:serialNub];
    _tipTextView.text = [NSString stringWithFormat:@"%@\ndiscoverABPMDevices:%@",_tipTextView.text,discoverABPMDevices];
    
}
-(void)deviceHTSDiscover:(NSNotification*)info {
    
    NSLog(@"Disover:%@",[info userInfo]);
    NSString *serialNub = [[info userInfo]valueForKey:@"SerialNumber"];
    self.tipTextView.text=[NSString stringWithFormat:@"扫描到设备：%@",serialNub];
    [discoverHTSDevices addObject:serialNub];
    _tipTextView.text = [NSString stringWithFormat:@"%@\ndiscoverHTSDevices:%@",_tipTextView.text,discoverHTSDevices];
}


-(void)deviceBP3LConnectFailed:(NSNotification*)info {
    NSLog(@"连接失败:%@",[info userInfo]);
    [[ScanDeviceController commandGetInstance]commandScanDeviceType:HealthDeviceType_BP3L];
}
-(void)deviceBP7SConnectFailed:(NSNotification*)info {
    NSLog(@"连接失败:%@",[info userInfo]);
}
-(void)deviceKN550BTConnectFailed:(NSNotification*)info {
    NSLog(@"连接失败:%@",[info userInfo]);
}
-(void)deviceKD926ConnectFailed:(NSNotification*)info {
    NSLog(@"连接失败:%@",[info userInfo]);
    [[ScanDeviceController commandGetInstance]commandScanDeviceType:HealthDeviceType_KD926];
}
-(void)deviceKD723ConnectFailed:(NSNotification*)info {
    NSLog(@"连接失败:%@",[info userInfo]);
    [[ScanDeviceController commandGetInstance]commandScanDeviceType:HealthDeviceType_KD723];
}
-(void)deviceABPMConnectFailed:(NSNotification*)info {
    NSLog(@"连接失败:%@",[info userInfo]);
    [[ScanDeviceController commandGetInstance]commandScanDeviceType:HealthDeviceType_ABPM];
}

-(void)deviceHTSConnectFailed:(NSNotification*)info {
    NSLog(@"连接失败:%@",[info userInfo]);
}


@end
