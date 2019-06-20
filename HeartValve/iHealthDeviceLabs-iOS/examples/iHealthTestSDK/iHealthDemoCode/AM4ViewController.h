//
//  AM4ViewController.h
//  iHealthDemoCode
//
//  Created by hejiasu on 16/5/19.
//  Copyright © 2016年 zhiwei jing. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AM4ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *textField;

- (IBAction)scanDevice:(UIButton *)sender;
- (IBAction)setUserID:(id)sender;


- (IBAction)stopScan:(UIButton *)sender;


- (IBAction)SyncActiveData:(UIButton *)sender;

- (IBAction)SyncSleepData:(id)sender;


- (IBAction)SyncCurrentActive:(id)sender;
- (IBAction)SyncStageData:(id)sender;

- (IBAction)commandAM4GetDeviceStateInfo:(id)sender;
- (IBAction)commandAM4ResetDevice:(id)sender;
- (IBAction)commandAM4Disconnect:(id)sender;

- (IBAction)commandAM4GetTotoalAlarmInfo:(id)sender;

- (IBAction)commandAM4SetAlarmDictionary:(id)sender;

- (IBAction)commandAM4DeleteAlarmID:(id)sender;
- (IBAction)commandAM4GetReminderInfo:(id)sender;
- (IBAction)commandAM4SetReminderDictionary:(id)sender;
- (IBAction)commandAM4GetTimeFormatAndNation:(id)sender;
- (IBAction)commandAM4GetUserInfo:(id)sender;
- (IBAction)commandAM4GetSwimmingInfo:(id)sender;
- (IBAction)back:(id)sender;

@end
