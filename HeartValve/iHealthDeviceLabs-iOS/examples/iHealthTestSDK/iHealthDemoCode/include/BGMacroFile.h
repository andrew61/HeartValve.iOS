//
//  BPMacroFile.h
//  BGDemoCode
//
//  Created by zhiwei jing on 14-6-29.
//  Copyright (c) 2014年 zhiwei jing. All rights reserved.
//

#import "HealthUser.h"

#ifndef BGDemoCode_BPMacroFile_h
#define BGDemoCode_BPMacroFile_h

typedef enum {
    BGOpenMode_Strip = 1,//BGOpenMode_Strip means booting the meter by sliding the strip
    BGOpenMode_Hand//BGOpenMode_Hand means booting the meter by pressing the on/off button.
}BGOpenMode;

typedef enum {
    BGMeasureMode_Blood = 1,//BGMeasureMode_Blood means blood measurement mode
    BGMeasureMode_NoBlood//BGMeasureMode_NoBlood means control solution measurement mode.
}BGMeasureMode;

typedef enum {
    BGUnit_mmolPL = 1,//BGUnit_mmolPL stands for mmol/L
    BGUnit_mgPmL//BGUnit_mgPmL stands for mg/dL
}BGUnit;


//
typedef void (^DisposeBGStripInBlock)(BOOL stripIn);
//
typedef void (^DisposeBGStripOutBlock)(BOOL stripOut);
//
typedef void (^DisposeBGBloodBlock)(BOOL blood);
//
typedef void (^DisposeBGResultBlock)(NSDictionary* result);
//
typedef void (^DisposeBGSendCodeBlock)(BOOL sendOk);
//
typedef void (^DisposeBGErrorBlock)(NSNumber* errorID);
/*
 errorID:
 00：Battery is low.
 01：Glucose test result is out of the measurement range.
 02：Unknown interference detected, please repeat the test.
 03：Strip is used or unknown moisture detected, discard the test strip and repeat the test with a new strip.
 04：Reading transmission error. Repeat the test with a new test strip. If the problem persists, contact iHealth customer service for assistance.
 05\06：The environmental temperature is beyond normal range, place the meter at room temperature for at least 30 minutes, then repeat the test.
 07：Test strip coding error.
 08：Communication error, press“START” or rescan the code to repeat the test.
 09：Strip removed in the middle of reading, repeat the test with a new strip.
 10: Insert a new test strip and repeat the test.
 11: Cannot write to SN or KEY.
 12: Please set time.
 13: 0 test strips remaining.
 14: Test strip expired.
 15: Unplug the charging cable before testing.
 100: BG meter disconnected.
 101: BG meter is in sleeping mode, needs repair.
 111: user verification failed.
*/
//
typedef void (^DisposeBGBottleID)(NSNumber *bottleID);
//
typedef void (^DisposeBGDataCount)(NSNumber* dataCount);
//
typedef void (^DisposeBGHistoryData)(NSDictionary *historyDataDic);
//
typedef void (^DisposeBGDeleteData)(BOOL deleteOk);
//
typedef void(^DisposeBGSendBottleIDBlock)(BOOL sendOk);
//
typedef void (^DisposeBGCodeDic)(NSDictionary *codeDic);
//
typedef void (^DisposeBGSendCodeBlock)(BOOL sendOk);
//
typedef void (^DisposeBGStartModel)(BGOpenMode mode);
//
typedef void (^DisposeBGTestModelBlock)(BGMeasureMode mode);
//
typedef void (^DisposeBGIDPSBlock)(NSDictionary* idpsDic);
//
typedef void (^DisposeDiscoverBGBlock)(BOOL result);
//
typedef void (^DisposeConnectBGBlock)(BOOL result);

typedef void (^DisposeAuthenticationBlock)(UserAuthenResult result);//the result of userID verification
//电池电量
typedef void (^DisposeBGBatteryBlock)(NSNumber* energy);

#define BGSDKRightApi  @"OpenApiBG"

#define BG3ConnectNoti @"BG3ConnectNoti"
#define BG3DisConnectNoti @"BG3DisConnectNoti"
#define BG5ConnectNoti @"BG5ConnectNoti"
#define BG5DisConnectNoti @"BG5DisConnectNoti"
#define BG5LConnectNoti @"BG5LConnectNoti"
#define BG5LDisConnectNoti @"BG5LDisConnectNoti"
#define BG1ConnectNoti @"BG1ConnectNoti"
#define BG1DisConnectNoti @"BG1DisConnectNoti"

#define BG5LDiscover        @"BG5LDiscover"
#define BG5LConnectFailed   @"BG5LConnectFailed"

#endif
