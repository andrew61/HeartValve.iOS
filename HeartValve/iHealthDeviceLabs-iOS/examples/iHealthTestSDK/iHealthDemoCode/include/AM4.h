//
//  AM4.h
//  iHealthApp2
//
//  Created by 小翼 on 14-7-2.
//  Copyright (c) 2014年 andon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AMMacroFile.h"

@interface AM4 : NSObject
@property (strong, nonatomic) NSMutableString *am4RandomString;
@property (strong, nonatomic) NSString *currentUUID;
@property (strong, nonatomic) NSString *serialNumber;
@property (strong, nonatomic) NSString *firmwareVersion;
@property (strong, nonatomic) NSNumber *battery;
@property (copy,   nonatomic) NSString *isInUpdateProcess;



/**
 * Establish memory and measurement connection,Only after verification through this interface can we move onto using other API's.
 * @param tempUser includes properties：clientID，clientSecret，userID.userID，either email or mobile phone number (mobile phone number not yet supported).ClientID and clientSecret, the only identification for users of the SDK, requires registration from iHealth administrator, please email:lvjincan@ihealthlabs.com.cn.com for more information
 * @param disposeAuthenticationBlock The return parameters of ’‘userid’, ’clientID’,and ‘clientSecret’ after verification.
 * The interpretation for the verification:
 *  1. UserAuthen_RegisterSuccess, New-user registration succeeded.
 *  2. UserAuthen_LoginSuccess， User login succeeded.
 *  3. UserAuthen_CombinedSuccess, The user is iHealth user as well, measurement via SDK has been activated, and the data from the measurement belongs to the user.
 *  4. UserAuthen_TrySuccess, testing without Internet connection succeeded.
 *  5. UserAuthen_InvalidateUserInfo, Userid/clientID/clientSecret verification failed.
 *  6. UserAuthen_SDKInvalidateRight, SDK has not been authorized.
 *  7. UserAuthen_UserInvalidateRight,User has not been authorized.
 *  8. UserAuthen_InternetError, Internet error, verification failed.
 *  --PS:
 *  The measurement via SDK will be operated in the case of 1-3, and will be terminated if any of 4-8 occurs. The interface needs to be re-called after analyzing the return parameters.
 *  @Notice  Notice: when a new user registers via SDK, an ‘iHealth disclaimer’ will pop up automatically, and will require the user to agree in order to continue. SDK applications require an Internet connection.
 * @param currentUserIDBlock Uniquely identifies the user, the SDK requires this to be stored. This ID will be sent to the AM4 and will allow the AM4 to pair with only this user.
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */
-(void)commandAM4CreateUserManageConnectWithUser:(HealthUser *)tempUser withAuthenticationResult:(BlockUserAuthentication)authenticationResultBlock withCurrentUserID:(CurrentSerialNub)currentUserIDBlock withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;


/**
 * Get device userID and user bined sevice MAC Address
 * @param getDeviceUserIDBlock The connected user's MAC Address
 * @param userBinedDeviceMACBlock The user's AM4 MAC Address
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */
-(void)commandAM4GetDeviceUserID:(DisposeAM4GetDeviceUserIDBlock)getDeviceUserIDBlock withFromCloudGetUserBinedDeviceMAC:(DisposeAM4GetUserBinedDeviceMACBlock)userBinedDeviceMACBlock withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;



/**
 * Sending a random number,This API sends a random number to the AM4. Only when the random number matches the number displayed on the AM4 screen can the device be bound to the device.
 * @param setRandomNumberBlock True: Sent successfully，False: Failed。Random number is six digits, ranging from 0 – 999999. AM4 will receive the random number and display on screen. The user will have to enter it into the app.
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */
-(void)commandAM4SetRandomNumber:(DisposeAM4SetRandomNumberBlock)setRandomNumberBlock withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;


/**
 * Sync time
 * @param syncTimeBlock True: Success， False: Failed.
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */
-(void)commandAM4SyncTime:(DisposeAM4SyncTimeBlock)syncTimeBlock withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;

/**
 * Set time format and nation
 * @param setTimeFormatBlock True: Success， False: Failed.
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */
-(void)commandAM4SetTimeFormatAndNation:(DisposeAM4TimeFormatAndNationSettingBlock)setTimeFormatBlock withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;

/**
 * Binding AM4 to user,Account binding requires an active internet connection.
 * @param userID userID.
 * @param finishResultBlock True: Success， False: Failed.
 * @param cloudBinedDevice True: Success， False: Failed.
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */
-(void)commandAM4SetUserID:(NSNumber*)userID withFinishResult:(DisposeAM4SetDeviceUserIDBlock)finishResultBlock withSetCloudBinedDevice:(DisposeAM4SetCloudBinedDevice)cloudBinedDevice withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;

/**
 * AM4 initialization,Must be called the first time to ensure that the AM4 has correct user information, goals, time, battery checks, etc.
 * @param user User information, needs to include the following：birthday(NSDate)、height(cm)、weight(kg)、bmr(user basal metabolic)、sex(UserSex_Female or UserSex_Male)、activityLevel (activityLevel=1, Sedentary,spend most of day sitting.activityLevel=2, Active,spend a good part of day doing some physical activity.activityLevel=3, Very Active,spend most of day doing heavy physical activity.)
 * @param unit AM4KmUnit_mile or AM4KmUnit_km
 * @param activeGoalNumber User goal number of steps. Default is 10,000
 * @param swimmingGoal User goal number of swimming. 
 * @param setUserInfoFinishBlock True: Success， False: Failed.
 * @param setBMRfinishResultBlock True: Success， False: Failed.
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */

-(void)commandAM4SetUserInfo:(HealthUser *)user withUnit:(AM4KmUnit)unit withActiveGoal:(NSNumber *)activeGoalNumber withSwimmingGoal:(NSNumber *)swimmingGoal withSetUserInfoFinishResult:(DisposeAM4SetUserInfoBlock)setUserInfoFinishBlock withSetBMR:(DisposeAM4SetBMRBlock)setBMRfinishResultBlock withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;



/**
 * Set swimming
 * @param swimmingIsOpen YES:open swimming function NO:close swimming function default:no
 * @param swimmingPoolLength swimming Pool Length
 * @param noSwimmingDate automatic drop out swim duration
 * @param unit swim unit (  AM4SwimmingUnit_m or AM4SwimmingUnit_km)
 * @param finishResultBlock True: Success， False: Failed.
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */
-(void)commandAM4SetSwimmingState:(BOOL)swimmingIsOpen withSwimmingPoolLength:(NSNumber *)swimmingPoolLength withNOSwimmingTime:(NSDate *)noSwimmingDate withUnit:(AM4SwimmingUnit)unit withFinishResult:(DisposeAM4SettingSwimmingBlock)finishResultBlock withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;

/**
 * Upload AM4 data,Data type: 5 minutes of motion data, total number of steps for the day, and total calories.Also includes the number of steps for the 5 minutes of motion data, total calories for the current time, calories of the steps, and total calories.
 * @param activeTransmissionBlock activeTransmission: Start uploading motion data, including parameters：StartActiveHistoryDate、StepSize、StartActiveHistoryTotoalNum.
 * @param activeHistoryDataBlock Start date，yyyy-MM-dd.StepSize：Length of each step, cm.StartActiveHistoryTotoalNum：Number of records.AM4historyData data，including the following parameters：AMDate、AMCalorie、AMStepNum.AMDate：Workout time， NSDate.AMCalorie: Current time total calories.AMStepNum：Total number of steps.
 * @param activeFinishTransmissionBlock Upload complete.
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */
-(void)commandAM4StartSyncActiveData:(DisposeAM4ActiveStartTransmission)activeTransmissionBlock
               withActiveHistoryData:(DisposeAM4ActiveHistoryData)activeHistoryDataBlock
        withActiveFinishTransmission:(DisposeAM4ActiveFinishTransmission)activeFinishTransmissionBlock withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;
/**
 * Upload AM4 data,Data type: 5 minutes of sleep data,
 * @param sleepTransmissionBlock Start uploading sleep data, including parameters：SleepActiveHistoryDate、StartActiveHistoryTotoalNum.SleepActiveHistoryDate：Sleep start time，yyyy-MM-dd HH:mm:ss.StartActiveHistoryTotoalNum: Number of records
 * @param sleepHistoryDataBlock Sleep data, including the following parameters:：AMDate、SleepData.AMDate：Sleep time, NSDate.SleepData: Sleep grade, 0: awake, 1: light sleep, 2: deep sleep.
 * @param sleepFinishTransmissionBlock Upload complete.
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */
-(void)commandAM4StartSyncSleepData:(DisposeAM4SleepStartTransmission)sleepTransmissionBlock withSleepHistoryData:(DisposeAM4SleepHistoryData)sleepHistoryDataBlock
        withSleepFinishTransmission:(DisposeAM4SleepFinishTransmission)sleepFinishTransmissionBlock withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;

/**
 * Upload AM4 data,Data type: Sync current active data
 * @param currentActiveInfoBlock Total calories and steps for today, including parameters：Step、Calories、TotalCalories.Step：Number of steps taken today.Calories：Number of calories burned today.TotalCalories：Sum calories burned and bmr today.
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */
-(void)commandAM4StartSyncCurrentActiveData:(DisposeAM4GetCurrentActiveInfo)currentActiveInfoBlock withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;



/**
 * Upload AM4 report data.
 * @param stageDataBlock Report data, including parameters: ReportStage_Swimming、ReportStage_Work_out、ReportStage_Sleep_summary. Currently only supports ReportStage_Work_out、ReportStage_Sleep_summar.Workout contains properties：ReportState、Work_outMeasureDate、Work_outTimeNumber、Work_outStepNumber、Work_outLengthNumber、Work_outCalories.ReportState：ReportStage_Work_out.Work_outMeasureDate：Start time.Work_outTimeNumber：Length of workout (mins).Work_outStepNumber：Workout number of steps.Work_outLengthNumber：Workout distance (km).Work_outCalories：Workout calories burned.Sleep contains properties：ReportState、Sleep_summaryMeasureDate、Sleep_summarySleepTime、Sleep_summarysleepEfficiency、Sleep_summarysleepAddMinute.ReportState：ReportStage_Sleep_summary.Sleep_summaryMeasureDate：Sleep start time.Sleep_summarySleepTime: Sleep duration (mins).Sleep_summarysleepEfficiency：Sleep efficiency percentage, range is 0-100.Sleep_summarysleepAddMinute：Correct sleep duration length. Change the length of time from before falling asleep to add onto the time awake.
 * @param stageDataFinishTransmissionBlock YES: Success，NO: Failed.
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */
-(void)commandAM4StartSyncStageData:(DisposeAM4MeasureDataBlock)stageDataBlock withStageDataFinishTransmission:(DisposeAM4WorkoutFinishBlock)stageDataFinishTransmissionBlock withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;


/**
 * Get totoal alarm infomation
 * @param totoalAlarmInfoBlock Alarm array contains up to 3 alarms, each one needs the following parameters：AlarmId、Time、IsRepeat、Switch、（Sun、Mon、Tue、Wed、Thu、Fri、Sat)AlarmId：1, 2, 3.Time：HH:mm.IsRepeat：Repeat alarm， True: Repeat， False: Don't repeat.Switch：Alarm on/off. True: On, False: Off.Sun、Mon、Tue、Wed、Thu、Fri、Sat：True.
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */
-(void)commandAM4GetTotoalAlarmInfo:(DisposeAM4TotoalAlarmData)totoalAlarmInfoBlock withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;

/**
 * Set alarm.
 * @param alarmDic Alarm information, include parameters：AlarmId、Time、IsRepeat、Switch、（Sun、Mon、Tue、Wed、Thu、Fri、Sat)
 * @param finishResultBlock True: Alarm set successfully，False: Failed.
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */
-(void)commandAM4SetAlarmDictionary:(NSDictionary *)alarmDic withFinishResult:(DisposeAM4SetAlarmBlock)finishResultBlock withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;


/**
 * Delete alarm.
 * @param alarmID alarmID：1, 2, 3.
 * @param finishResultBlock True: Delete successful，False: Failed
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */
-(void)commandAM4DeleteAlarmID:(NSNumber *)alarmID withFinishResult:(DisposeAM4DeleteAlarmBlock)finishResultBlock withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;

/**
 * Get reminder.
 * @param remindInfoBlock Array containing following parameters：Time、Switch.Time：format HH:mm, time between reminders (HH*60+mm) minutes.Switch：Reminder on/off，True: On， False: Off.
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */
-(void)commandAM4GetReminderInfo:(DisposeAM4RemindAM4InfoBlock)remindInfoBlock withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;

/**
 * Set reminders.
 * @param reminderDic Array containing collowing parameters：Time、Switch。
 * @param finishResultBlock YES: Successfully set, NO: Failed.
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */
-(void)commandAM4SetReminderDictionary:(NSDictionary *)reminderDic withFinishResult:(DisposeAM4SetReminderBlock)finishResultBlock withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;



/**
 * Get device state infomation
 * @param deviceStateInfoBlock AM status，State_wrist  (AM4 being worn on the wrist)，State_waist (AM4 worn with belt clip).
 * @param batteryBlock AM battery percentage, from 0～100.
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */
-(void)commandAM4GetDeviceStateInfo:(DisposeAM4StateInfoBlock)deviceStateInfoBlock withBattery:(DisposeAM4BatteryBlock)batteryBlock withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;

/**
 * Restore factory settings.
 * @param resetDeviceBlock True: Success， False: Failed.
 * @param cloudDisBinedDevice True: Success， False: Failed.
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */
-(void)commandAM4ResetDevice:(DisposeAM4ResetDeviceBlock)resetDeviceBlock withFromCloudDisBinedDevice:(DisposeAM4FromCloudDisBinedDeviceBlock)cloudDisBinedDevice withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;

/**
 * Disconnect AM4 connection.
 * @param disconnectBlock  True: Success，False: Failed.
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */
-(void)commandAM4Disconnect:(DisposeAM4DisconnectBlock)disconnectBlock withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;


/**
 * Get time format and nation
 * @param timeAndNationBlock  (AM4TimeFormat_hh,AM4TimeFormat_HH,AM4TimeFormat_NoEuropeAndhh,AM4TimeFormat_EuropeAndhh,AM4TimeFormat_NoEuropeAndHH,AM4TimeFormat_EuropeAndHH)
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */
-(void)commandAM4GetTimeFormatAndNation:(DisposeAM4TimeFormatAndNationBlock)timeAndNationBlock withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;




/**
 * Get user infomation
 * @param userInfoBlock including parameters:age,steplength,height,gender,weight,unit,goal
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */
-(void)commandAM4GetUserInfo:(DisposeAM4UserInfoBlock)userInfoBlock withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;

/**
 * Get swimming infomation
 * @param swimmingInfoBlock including parameters:swimmingIsOpen,swimmingPoollength,NOSwimmingTime,unit
 * @param errorBlock Communication error codes, see AM4 error descriptions.
 */
-(void)commandAM4GetSwimmingInfo:(DisposeAM4SwimmingBlock)swimmingInfoBlock withErrorBlock:(DisposeAM4ErrorBlock)errorBlock;

@end