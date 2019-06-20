//
//  AMMacroFile.h
//  AMDemoCode
//
//  Created by zhiwei jing on 14-8-12.
//  Copyright (c) 2014年 zhiwei jing. All rights reserved.
//

#import "HealthUser.h"

#ifndef AMDemoCode_AMMacroFile_h
#define AMDemoCode_AMMacroFile_h

//AM3
typedef enum{
    Sleep_State = 0,//sleep
    Active_State = 1,//sport
    Fly_State = 2, //flight        validate
    Drive_State = 3//drive         validate
}ActiveState;

typedef enum{
    State_waist,//
    State_wrist,//
    State_sleep//
}QueryAM3State;


typedef enum{
    AMErrorOverTime = 0,//Communication error
    AM_Reset_Device_Faild,//Reset failed
    AMErrorDisconnect,//AM disconnect
    AMErrorUserInvalidate//invalidate user info
}AMErrorID;

//
typedef enum{
    SingleCommand=0,//
    ProcessCommand  //
}Command_State;


//AM3S
typedef enum{
    Picture_one,//
    Picture_two,//
}AM3SPicture;


typedef enum{
    TimeFormat_HH,//
    TimeFormat_hh,//
}AM3STimeFormat;

typedef enum{
    SwimmingAction_Breaststroke,//,
    SwimmingAction_Crawl,//
    SwimmingAction_Backstroke, //
    SwimmingAction_Butterfly,//
}AM3SSwimmingAction;


typedef enum{
    ReportStage_Swimming,
    ReportStage_Work_out,
    ReportStage_Sleep_summary,
    ReportStage_Activeminutes,
}AM3SReportStage;


typedef enum{
    AM3SActive_State = 0,//sport
    AM3SSleep_State = 1,//sleep
    AM3SFly_State = 2, //flight           validate
    AM3SWorkout_State = 4, //workout
    AM3SSwimming_State = 5, //swim
}AM3SActiveState;

typedef enum{
    AM3SState_waist,//
    AM3SState_wrist,//
    AM3SState_sleep//
}QueryAM3SState;

typedef enum{
    AM3SErrorOverTime = 0, //Communication error
    AM3S_Reset_Device_Faild, //Reset failed
    AM3SErrorDisconnect, //AM disconnect
    AM3SErrorUserInvalidate//invalidate user info
}AM3SErrorID;

//
typedef enum{
    AM3SSingleCommand=0,
    AM3SProcessCommand
}AM3SCommand_State;


//AM4
typedef enum{
    AM4ErrorOverTime = 0,    //Communication error
    AM4ErrorNoRespond,       //You did not receive a response within a certain period of time, usually clogged Bluetooth
    AM4ErrorResetDeviceFaild,//Reset failed
    AM4ErrorDisconnect,       //AM disconnect
    AM4ErrorParameterError,    //ParameterError
    AM4ErrorNetworkError,    //ParameterError
    AM4ErrorUserInvalidate    //invalidate user info
}AM4ErrorID;
typedef enum{
    AM4TimeFormat_hh,//12
    AM4TimeFormat_HH,//24
    AM4TimeFormat_NoEuropeAndhh,//
    AM4TimeFormat_EuropeAndhh,
    AM4TimeFormat_NoEuropeAndHH,
    AM4TimeFormat_EuropeAndHH,
}AM4TimeFormatAndNation;
typedef enum{
    AM4KmUnit_mile,
    AM4KmUnit_km,
}AM4KmUnit;
typedef enum{
    AM4SwimmingUnit_m,
    AM4SwimmingUnit_km,
}AM4SwimmingUnit;
typedef enum{
    AM4State_waist,
    AM4State_wrist,
    AM4State_sleep
}AM4QueryState;
typedef enum{
    AM4Picture_one,
    AM4Picture_two,
}AM4Picture;
typedef enum{
    AM4SwimmingAction_Crawl,
    AM4SwimmingAction_Breaststroke,
    AM4SwimmingAction_Backstroke,
    AM4SwimmingAction_Butterfly,
    AM4SwimmingAction_MixedSwimming,
    AM4SwimmingAction_Unkonw
}AM4SwimmingAction;
typedef enum{
    AM4ReportStage_Swimming,
    AM4ReportStage_Work_out,
    AM4ReportStage_Sleep_summary,
}AM4ReportStage;
typedef enum{
    AM4Active_State =0,
    AM4Sleep_State =1,
    AM4Fly_State =2,
    AM4Workout_State=4,
    AM4Swimming_State=5,
}AM4ActiveState;
typedef enum{
    AM4Gender_Male = 0,
    AM4Gender_Female
}AM4Gender;




/*
    UserAuthen_RegisterSuccess: New-user registration succeeded.
    UserAuthen_LoginSuccess: User login succeeded.
    UserAuthen_CombinedSuccess: The user is an iHealth user as well, measurement via SDK has been activated, and the data from the measurement belongs to the user.
    UserAuthen_TrySuccess: Testing without internet connection succeeded.
    UserAuthen_InvalidateUserInfo: Userid/clientID/clientSecret verification failed.
    UserAuthen_SDKInvalidateRight: SDK has not been authorized.
    UserAuthen_UserInvalidateRight: User has not been authorized.
    UserAuthen_InternetError: Internet error, verification failed.
    The measurement via SDK will be operated in the case of 1-3, and will be terminated if any of 4-8 occurs. The interface needs to be re-called after analyzing the return parameters.
 
    Notice: when a new user registers via SDK, an ‘iHealth disclaimer’ will pop up automatically, and will require the user to agree in order to continue. SDK applications require an Internet connection.
 
*/
typedef void (^BlockUserAuthentication)(UserAuthenResult result);//the result of userID verification

//Uniquely identifies the user, the SDK requires this to be stored. This ID will be sent to the AM3 and will allow the AM3 to pair with only this user.
typedef void (^CurrentSerialNub)(NSInteger serialNub);
//The user's AM3's MAC Address
typedef void (^DisposeBinedAMSerialNub) (NSString *binedSerialNub);
//The connected user's MAC Address
typedef void (^DisposeCurrentSerialNub) (NSString *currentSerialNub);

//YES: Account bonding successfu. NO: Failed
typedef void (^DisposeBinedUserResult) (BOOL result);
//True: Success，False: Failed.
typedef void (^DisposeDisBinedUserResult) (BOOL result);

//
typedef void (^DisposeQueryBinedSerialNub) (NSString *serialNub);


#define AMStepNum @"AMstepNum"
#define AMStepSize @"AMstepSize"
#define AMCalorie @"AMcalorie"
#define AMDate @"AMDate"
#define AMQuerState "AMQuerState"

#define TimeInterval @"TimeInterval"
#define StartActiveHistoryTotoalNum @"StartActiveHistoryTotoalNum"
#define StateFlage @"StateFlage"

#define AM3Discover        @"AM3Discover"
#define AM3ConnectFailed   @"AM3ConnectFailed"
#define AM3ConnectNoti @"AM3ConnectNoti"
#define AM3DisConnectNoti @"AM3DisConnectNoti"

#define AM3SDiscover        @"AM3SDiscover"
#define AM3SConnectFailed   @"AM3SConnectFailed"
#define AM3SConnectNoti @"AM3SConnectNoti"
#define AM3SDisConnectNoti @"AM3SDisConnectNoti"

#define AM4Discover        @"AM4Discover"
#define AM4ConnectFailed   @"AM4ConnectFailed"
#define AM4ConnectNoti @"AM4ConnectNoti"
#define AM4DisConnectNoti @"AM4DisConnectNoti"

#define AMDeviceID @"ID"
#define AMSDKSportRightApi  @"OpenApiActivity"
#define AMSDKSleepRightApi  @"OpenApiSleep"



///////////////////////////////////////////////////////////////

#define AM4StepNum @"AM4stepNum"
#define AM4StepSize @"AM4stepSize"
#define AM4Calorie @"AM4calorie"
#define AM4Date @"AM4Date"
#define AM4QuerState "AM4QuerState"

#define AM4SleepActiveHistoryDateYear @"SleepActiveHistoryDateYear"
#define AM4SleepActiveHistoryDateMonth @"SleepActiveHistoryDateMonth"
#define AM4SleepActiveHistoryDateDay @"SleepActiveHistoryDateDay"
#define AM4SleepActiveHistoryDateHour @"SleepActiveHistoryDateHour"
#define AM4SleepActiveHistoryDateMinute @"SleepActiveHistoryDateMinute"
#define AM4SleepActiveHistoryDateSeconds @"SleepActiveHistoryDateSeconds"
#define AM4TimeInterval @"TimeInterval"
#define AM4StartActiveHistoryTotoalNum @"StartActiveHistoryTotoalNum"
#define AM4StateFlage @"StateFlage"

#define AM4SwimmingMeasureDate @"SwimmingMeasureDate"
#define AM4SwimmingTimeNumber @"SwimmingTimeNumber"
#define AM4SwimmingTimes @"SwimmingTimes"
#define AM4Swimmingcalories @"Swimmingcalories"
#define AM4SwimmingAct @"SwimmingAct"
#define AM4SwimmingPoollength @"SwimmingPoollength"
#define AM4SwimmingCircleCount @"SwimmingCircleCount"
#define AM4EnterSwimmingTime @"EnterSwimmingTime"
#define AM4OutSwimmingTime @"OutSwimmingTime"
#define AM4SwimmingProcessMark @"SwimmingProcessMark"
#define AM4SwimStartTimeStamp @"SwimStartTimeStamp"


#define AM4Work_outMeasureDate @"Work_outMeasureDate"
#define AM4Work_outTimeNumber @"Work_outTimeNumber"
#define AM4Work_outStepNumber @"Work_outStepNumber"
#define AM4Work_outLengthNumber @"Work_outLengthNumber"
#define AM4Work_outCalories @"Work_outCalories"

#define AM4Sleep_summaryMeasureDate @"Sleep_summaryMeasureDate"
#define AM4Sleep_summarySleepTime @"Sleep_summarySleepTime"
#define AM4Sleep_summarysleepEfficiency @"Sleep_summarysleepEfficiency"
#define AM4Sleep_summarysleepAddMinute @"Sleep_summarysleepAddMinute"

#define AM4ReportState @"ReportState"
#define AM4ActiveminutesMeasureDate @"ActiveminutesMeasureDate"
#define AM4ActiveminutesTime @"ActiveminutesTime"



typedef void (^DisposeAM4GetUserBinedDeviceMACBlock)(NSString *deviceMAC);//UserBinedDeviceMAC
typedef void (^DisposeAM4GetDeviceUserIDBlock)(unsigned int userID);//userID

typedef void (^DisposeAM4ErrorBlock)(AM4ErrorID errorID);//Communication error codes, see AM4 error descriptions.

typedef void (^DisposeAM4SetRandomNumberBlock)(NSString *randomNumString);//random number

typedef void (^DisposeAM4SyncTimeBlock)(BOOL resetSuc);//SyncTime

typedef void (^DisposeAM4TimeFormatAndNationBlock)(AM4TimeFormatAndNation  timeFormatAndNation);////dateFormatter

typedef void (^DisposeAM4TimeFormatAndNationSettingBlock)(BOOL resetSuc);////setdateFormatter

typedef void (^DisposeAM4SetDeviceUserIDBlock)(BOOL resetSuc);//set user ID
typedef void (^DisposeAM4SetCloudBinedDevice)(BOOL resetSuc);//set user ID



typedef void (^DisposeAM4SetUserInfoBlock)(BOOL resetSuc);//set user infomation


typedef void (^DisposeAM4SetBMRBlock)(BOOL resetSuc);//setBMR


typedef void (^DisposeAM4ActiveStartTransmission)(NSDictionary *startDataDictionary);//Start uploading motion data
typedef void (^DisposeAM4ActiveHistoryData)(NSArray *historyDataArray);//sportData
typedef void (^DisposeAM4ActiveFinishTransmission)();//Upload motion complete


typedef void (^DisposeAM4SleepStartTransmission)(NSDictionary *startDataDictionary);//Start uploading sleep data
typedef void (^DisposeAM4SleepHistoryData)(NSArray *historyDataArray);//sleepData
typedef void (^DisposeAM4SleepFinishTransmission)();//Upload sleep complete

typedef void (^DisposeAM4GetCurrentActiveInfo)(NSDictionary *activeDictionary);//Total calories and steps for today, including parameters：Step、Calories、TotalCalories

typedef void (^DisposeAM4ResetDeviceBlock)(BOOL resetSuc);//Restore factory settings.
typedef void (^DisposeAM4FromCloudDisBinedDeviceBlock)(BOOL resetSuc);//Restore factory settings.



typedef void (^DisposeAM4TotoalAlarmData)(NSMutableArray *totoalAlarmArray);//Alarm array contains up to 3 alarms, each one needs the following parameters：AlarmId、Time、IsRepeat、Switch、（Sun、Mon、Tue、Wed、Thu、Fri、Sat)
typedef void (^DisposeAM4SetAlarmBlock)(BOOL resetSuc);//set Alarm
typedef void (^DisposeAM4DeleteAlarmBlock)(BOOL resetSuc);//delete Alarm


typedef void (^DisposeAM4RemindAM4InfoBlock)(NSArray *remindInfo);//remind
typedef void (^DisposeAM4SetReminderBlock)(BOOL resetSuc);//set remind


typedef void (^DisposeAM4StateInfoBlock)(AM4QueryState queryState);//query State
typedef void (^DisposeAM4BatteryBlock)(NSNumber *battery);//AM battery percentage, from 0～100.
typedef void (^DisposeAM4DisconnectBlock)(BOOL resetSuc);//disconnect


typedef void (^DisposeAM4SwimmingBlock)(BOOL swimmingIsOpen, NSNumber * swimmingLaneLength,NSNumber * NOSwimmingTime, AM4SwimmingUnit unit);//query swimming
typedef void (^DisposeAM4SettingSwimmingBlock)(BOOL resetSuc);//set swimming


typedef void (^DisposeAM4MeasureDataBlock)(NSArray *measureDataArray);
typedef void (^DisposeAM4WorkoutFinishBlock)(BOOL resetSuc);


typedef void (^DisposeAM4UserInfoBlock)(NSDictionary *userInfo);//query userinfo


#endif
