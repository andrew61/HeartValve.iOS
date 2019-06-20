//
//  CrashHelper.m
//  MyHealthApp
//
//  Created by Jonathan on 2/12/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "CrashHelper.h"
#import <CrashReporter/CrashReporter.h>
#import "AFNetworking.h"

NSString * const CrashReportEmailFromAddress = @"usersupport@hitechnologysolutions.com";
NSString * const CrashReportEmailToAddress = @"usersupport@hitechnologysolutions.com;";
NSString * const MandrillAPIBaseURL = @"https://mandrillapp.com/";
NSString * const MandrillAPIKey = @"TZf2prozJLVqCADdB70sAQ";
NSString * const AppBaseURL = @"https://hitechnologysolutions.com/HeartValve_API/";

@implementation CrashHelper

+ (CrashHelper *)sharedHelper
{
    static CrashHelper *sharedHelper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedHelper = [[self alloc] init];
    });
    return sharedHelper;
}

- (void)checkForCrashes
{
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    
    if ([crashReporter hasPendingCrashReport]) {
        [self sendCrashReport];
    }
    
    [crashReporter enableCrashReporter];
}

- (void)sendCrashReport
{
    PLCrashReporter *crashReporter = [PLCrashReporter sharedReporter];
    NSError *error;
    
    NSData *crashData = [crashReporter loadPendingCrashReportDataAndReturnError:&error];
    if (crashData == nil) {
        [crashReporter purgePendingCrashReport];
        return;
    }
    
    PLCrashReport *crashReport = [[PLCrashReport alloc] initWithData:crashData error:&error];
    if (crashReport == nil) {
        [crashReporter purgePendingCrashReport];
        return;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy H:mm:ss"];
    
    NSString *crashReportString = [NSString stringWithFormat:@"<p>Crashed on: %@</p>", [formatter stringFromDate:crashReport.systemInfo.timestamp]];
    
    if(crashReport.signalInfo != nil){
        crashReportString = [crashReportString stringByAppendingString:[NSString stringWithFormat:@"<p>Signal name: %@</p>", crashReport.signalInfo.name]];
        crashReportString = [crashReportString stringByAppendingString:[NSString stringWithFormat:@"<p>Signal code: %@</p>", crashReport.signalInfo.code]];
        crashReportString = [crashReportString stringByAppendingString:[NSString stringWithFormat:@"<p>Signal address: %lld</p>", crashReport.signalInfo.address]];
    }

    if(crashReport.exceptionInfo != nil){
        crashReportString = [crashReportString stringByAppendingString:[NSString stringWithFormat:@"<p>Exception name: %@</p>", crashReport.exceptionInfo.exceptionName]];
        crashReportString = [crashReportString stringByAppendingString:[NSString stringWithFormat:@"<p>Exception info: %@</p>", crashReport.exceptionInfo.exceptionReason]];
    }

//    AFHTTPSessionManager *session = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:MandrillAPIBaseURL]];
//    NSString *bundleDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
//    NSString *subject = [NSString stringWithFormat:@"%@ iOS Error", bundleDisplayName];
//    NSDictionary *params = @{
//                             @"key" : MandrillAPIKey,
//                             @"message" : @{
//                                     @"html" : crashReportString,
//                                     @"subject" : subject,
//                                     @"from_email" : CrashReportEmailFromAddress,
//                                     @"to" : [NSArray arrayWithObject:@{
//                                                                        @"email" : CrashReportEmailToAddress,
//                                                                        @"name" : CrashReportEmailToAddress,
//                                                                        @"type" : @"to"
//                                                                        }]
//                                     }
//                             };
//    
//    [session POST:@"api/1.0/messages/send.json" parameters:params
//          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
//              [crashReporter purgePendingCrashReport];
//          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//          }];
    
    AFHTTPSessionManager *session = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:AppBaseURL]];
    NSString *bundleDisplayName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
    NSString *subject = [NSString stringWithFormat:@"%@ iOS Error", bundleDisplayName];
    NSDictionary *params = @{
                             @"subject" : subject,
                             @"body" : crashReportString
                             };
    
    [session POST:@"api/Error" parameters:params
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
              [crashReporter purgePendingCrashReport];
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
          }];
}

@end
