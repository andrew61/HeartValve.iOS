//
//  ABPM.h
//  MedicaApp
//
//  Created by zhiwei jing on 13-12-5.
//  Copyright (c) 2013年 apple. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BPMacroFile.h"

typedef enum {
    ABPM_API_Free,
    ABPM_API_Function,
    ABPM_API_Energy,
    ABPM_API_Batch,
    ABPM_API_AskTime,
    ABPM_API_SetTime
}ABPM_API;


@interface ABPM : NSObject{
    ABPM_API ABPM_API_Status;
    
    BlockDeviceFounction _blockFounction;
    BlockError _blockError;
    
    BlockEnergyValue _blockEnergyValue;
    BlockBachCount _blockBachCount;
    BlockBachProgress _blockBachProgress;
    BlockBachArray _blockBachArray;
    BlockBachFinished _blockBachFinished;
    
    BlockAskMeasureTime _blockAskMeasureTime;
    BlockSetMeasureTime _blockSetMeasureTime;
    
    BlockUserAuthentication _blockUserAnthen;
    
    NSString *clientSDKUserName;
    NSString *clientSDKID;
    NSString *clientSDKSecret;
    
    int totalBatchCount;
    int uploadCountSum;
    NSString *thirdUserID;
    BOOL uploadOfflineNumFlg;
}

@property (strong, nonatomic) NSString *currentUUID;
@property (strong, nonatomic) NSString *serialNumber;
@property (retain, nonatomic) NSString *firmwareVersion;
@property (retain, nonatomic) NSString *protocol;
@property (retain, nonatomic) NSString *deviceName;

/**
 * Synchronize time and judge if the device supports the function of up Air Measurement, arm Measurement, Angle Sensor, Angle Setting, HSD, Offline Memory, mutable Groups Upload, Self Upgrade. ‘True’ means yes or on, ‘False’ means no or off.
 * @param Function  A block to return the function and states that the device supports.
 * @param error  A block to refer ‘error’ in ‘Establish measurement connection’ in KD926.
 */
-(void)commandFounction:(BlockDeviceFounction)founction errorBlock:(BlockError)error;

/**
 * Query battery remaining energy.
 * @param energyValue  A block to return the device battery remaining energy percentage, ‘80’ stands for 80%.
 * @param error  A block to return the error in ‘Establish measurement connection’
 */
-(void)commandEnergy:(BlockEnergyValue)energyValue errorBlock:(BlockError)error;

/**
 * Upload offline data total Count.
 * @param  TotalCount: item quantity of total data
 * @param error  A block to return the error
 */

-(void)commandTransferMemorytotalCount:(BlockBachCount)totalCount errorBlock:(BlockError)error;

/**
 * Upload offline data.
 * @param userID  the only identification for the user，by the form of email or cell phone #(cell-phone-# form is not supported temperately).
 * @param clientID  see bellow.
 * @param clientsecret  ‘clientID’ and ‘clientsecret’ are the only identification for user of SDK, are required registration from iHealth administrator, please email: lvjincan@ihealthlabs.com.cn.com for more information.
 * @param disposeAuthenticationBlock   A block to return parameter of ‘userid’, ’clientID’, ’clientSecret’ after the verification.
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
 *  The measurement via SDK will be operated in the case of 1-4, and will be terminated if any of 5-8 occurs. The interface needs to be re-called after analyzing the return parameters.
 *  @Notice   By the first time of new user register via SDK, ‘iHealth disclaimer’ will pop up automatically, and require the user agrees to continue. SDK application requires Internet connection; there is 10-day tryout if SDK cannot connect Internet, SDK is fully functional during tryout period, but will be terminated without verification through Internet after 10 days.
 * @param  groupNumber: the group number to upload in multiple groups memery situation.
 * @param  TotalCount: item quantity of total data
 * @param  Progress: upload completion ratio , from 0.0 to 1.0 or 0%~100％, 100% means upload completed.
 * @param  UploadDataArray:	offline data set, including measurement time, systolic pressure, diastolic pressure, pulse rate, irregular judgment. corresponding KEY as time, sys, dia, heartRate, irregular.
 * @param batchFinished: the block return when the offline data upload completed.
 * @param error   error codes.
 * Specification:
 *   1.  BPNormalError:  device error, error message displayed automatically.
 *   2.  BPOverTimeError:   communication over time error.
 *   3.  BPNoRespondError:   abnormal communication.
 *   4.  BPBeyondRangeError:   device is out of communication range.
 *   5.  BPDidDisconnect:   device is disconnected.
 *   6.  BPAskToStopMeasure:   measurement has been stopped.
 */
-(void)commandTransferMemoryDataWithUser:(NSString *)userID clientID:(NSString *)clientID clientSecret:(NSString *)clientSecret Authentication:(BlockUserAuthentication)disposeAuthenticationBlock  totalCount:(BlockBachCount)totalCount pregress:(BlockBachProgress)progress dataArray:(BlockBachArray)uploadDataArray finish:(BlockBachFinished)batchFinished errorBlock:(BlockError)error;


/**
 * Query the automatic cycle measurement setup of the device
 * @param  measureTimeDic: the dictionary contains the automatic cycle measurement setup of the current ABPM device. the object of the key @"sleeparray" is an array contains the measuring time interval after sleep and sleep,the members order is：the hour of after sleep time,the minute of after sleep time,the measure time interval of after sleep time,the hour of start sleep time,the minute of start sleep time,the measure time interval in sleep.the object of the key @"naparray" is an array contains the measuring time interval after nap and nap,the members order is similar to the sleep array.the object of the key @"measuretotaltime" is the total measure time of this measurement process that the user set.
 * @param error  A block to return the error
 */
-(void)commandAskAutoMeasureTime:(BlockAskMeasureTime)measureTimeDic errorBlock:(BlockError)error;

/**
 * Set the automatic cycle measurement interval and returns the information of the energy level of the blood pressure meter
 * @param sleepTimeArray is an array to set the measuring time interval after sleep and sleep,the members order need to be：the hour of after sleep time,the minute of after sleep time,the measure time interval of after sleep time,the hour of start sleep time,the minute of start sleep time,the measure time interval in sleep.
 * @param napTimeArray is an array to the measuring time interval after nap and nap,the members order need to be: the hour of after nap time,the minute of after nap time,the measure time interval of after nap time,the hour of start nap time,the minute of start nap time,the measure time interval in nap.
 * @param totalHour Set the automatic cycle measure total time.
 * @param setResult A block to return the  battery level and the measure time of the remaining energy could support,the corresponding keys are @"batterylevel" and @"measurecount".
 * @param error  A block to return the error.
 */
-(void)commandSetAutoMeasureTimeWithSleepTimeSection:(NSArray *)sleepTimeArray napTimeSection:(NSArray *)napTimeArray totalTime:(NSNumber *)totalHour result:(BlockSetMeasureTime)setResult errorBlock:(BlockError)error;

/**
 * Disconnect current device
 */
-(void)commandDisconnectDevice;

@end
