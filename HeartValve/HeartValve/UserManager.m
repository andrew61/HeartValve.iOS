//
//  UserManager.m
//  MyHealthApp
//
//  Created by Jonathan on 1/7/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "UserManager.h"
#import "User.h"
#import "BloodPressureMeasurement.h"
#import "WeightMeasurement.h"
#import "BloodGlucoseMeasurement.h"
#import "OxygenSaturation.h"
#import "JNKeychain.h"
#import "LoginInformation.h"
#import "AppVersion.h"
#import <CoreLocation/CoreLocation.h>
#import <sys/utsname.h>
#import "AppDelegate.h"
#import "DateFormatters.h"
#import "NSString+Encode.h"
#import "Survey.h"
#import "SurveyQuestion.h"
#import "SurveyQuestionOptions.h"
#import "SurveyAnswer.h"
#import "Enrollment.h"
#import "ActivationStatus.h"


@import CoreTelephony;

NSString * const UserManagerBaseURL = @"https://hitechnologysolutions.com/HeartValve_API/";
NSString * const ClientId = @"HeartValveIOS";
NSString * const ClientSecret = @"b49a93b7-7588-44d1-bde4-cd5cae55ebfd";

@implementation UserManager
{
    AFHTTPRequestSerializer *httpRequestSerializer;
    AFJSONRequestSerializer *jsonRequestSerializer;
}

@synthesize currentUser = _currentUser;

+ (UserManager *)sharedManager
{
    static UserManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
        
    });
    return sharedManager;
}

- (id)init
{
    if (self = [super initWithBaseURL:[NSURL URLWithString:UserManagerBaseURL]])
    {
        httpRequestSerializer = [AFHTTPRequestSerializer serializer];
        jsonRequestSerializer = [AFJSONRequestSerializer serializer];
    }
    return self;
}

+ (NSDictionary *)modelClassesByResourcePath
{
    return @{
             @"api/BloodPressure/*": [BloodPressureMeasurement class],
             @"api/Weight/*": [WeightMeasurement class],
             @"api/BloodGlucose/*": [BloodGlucoseMeasurement class],
             @"api/OxygenSaturation/*": [OxygenSaturation class],
             @"api/LoginInformation/*": [LoginInformation class],
             @"api/AppVersion/*": [AppVersion class],
             @"api/Survey/*": [Survey class],
             @"api/SurveyQuestion/*": [SurveyQuestion class],
             @"api/SurveyQuestionOptions/*": [SurveyQuestionOptions class],
             
             @"api/User/*": [User class],
             @"api/User/Enrollment": [Enrollment class],
             @"api/User/ActivationStatus": [ActivationStatus class]

             };
}

- (User *)currentUser
{
    if (_currentUser == nil)
    {
        _currentUser = [User new];
        
        NSDictionary *auth = [JNKeychain loadValueForKey:@"auth"];
        
        if (auth != nil)
        {
            _currentUser.userName = auth[@"username"];
        }
    }
    
    return _currentUser;
}

- (void)authorize:(void (^)(void))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized(self)
        {
            dispatch_semaphore_t sem = dispatch_semaphore_create(0);
            
            [self refreshToken:^(BOOL success, NSError *error) {
                dispatch_semaphore_signal(sem);
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (success)
                    {
                        NSDictionary *auth = [JNKeychain loadValueForKey:@"auth"];
                        NSString *authString = [NSString stringWithFormat:@"Bearer %@", auth[@"access_token"]];
                        [self setRequestSerializer:jsonRequestSerializer];
                        [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
                        [self.requestSerializer setValue:authString forHTTPHeaderField:@"Authorization"];
                        
                        if (completion) {
                            completion();
                        }
                    }
                    else
                    {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kAuthenticationDidExpireNotification object:nil];
                    }
                });
            }];
            
            dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
        }
    });
}

- (void)logIn:(NSString *)username password:(NSString *)password completion:(void (^)(User *, NSError *))completion
{
    [self setRequestSerializer:httpRequestSerializer];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *params = @{
                             @"username" : username,
                             @"password" : password,
                             @"grant_type" : @"password",
                             @"client_id" : ClientId,
                             @"client_secret" : ClientSecret
                             };
    
    [self POST:@"Token" parameters:params
       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
           NSDictionary *result = ((OVCResponse *)responseObject).result;
           NSDate *now = [NSDate date];
           NSString *expiresIn = [result valueForKey:@"expires_in"];
           NSDate *expires = [now dateByAddingTimeInterval:[expiresIn doubleValue]];
           NSDictionary *auth = @{
                                  @"access_token" : [result valueForKey:@"access_token"],
                                  @"refresh_token" : [result valueForKey:@"refresh_token"],
                                  @"expires" : expires,
                                  @"username" : [result valueForKey:@"userName"],
                                  @"password" : password
                                  };
           
           [JNKeychain saveValue:auth forKey:@"auth"];
           
           if (completion) {
               completion(self.currentUser, nil);
           }
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           NSLog(@"Login failed - %@", error.description);
           self.currentUser = nil;
           
           if (completion) {
               completion(self.currentUser, error);
           }
       }];
}

- (void)refreshToken:(void (^)(BOOL success, NSError *error))completion
{
    NSDictionary *auth = [JNKeychain loadValueForKey:@"auth"];
    
    if (auth != nil)
    {
        NSString *refreshToken = auth[@"refresh_token"];
        NSDate *expires = auth[@"expires"];
        NSDate *now = [NSDate date];
        NSString *password = auth[@"password"];
        
        if ([now timeIntervalSinceDate:expires] > 0)
        {
            [self setRequestSerializer:httpRequestSerializer];
            [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [self.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            
            NSDictionary *params = @{
                                     @"grant_type" : @"refresh_token",
                                     @"refresh_token" : refreshToken,
                                     @"client_id" : ClientId,
                                     @"client_secret" : ClientSecret
                                     };
            
            [self POST:@"Token" parameters:params
               success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
                   NSDictionary *result = ((OVCResponse *)responseObject).result;
                   NSDate *now = [NSDate date];
                   NSString *expiresIn = [result valueForKey:@"expires_in"];
                   NSDate *expires = [now dateByAddingTimeInterval:[expiresIn doubleValue]];
                   NSDictionary *auth = @{
                                          @"access_token" : [result valueForKey:@"access_token"],
                                          @"refresh_token" : [result valueForKey:@"refresh_token"],
                                          @"expires" : expires,
                                          @"username" : [result valueForKey:@"userName"],
                                          @"password" : password
                                          };
                   
                   [JNKeychain saveValue:auth forKey:@"auth"];
                   
                   if (completion) {
                       completion(YES, nil);
                   }
               } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                   NSLog(@"%@", error.description);
                   
                   if (completion) {
                       completion(NO, error);
                   }
               }];
        }
        else
        {
            if (completion) {
                completion(YES, nil);
            }
        }
    }
    else
    {
        if (completion) {
            completion(NO, nil);
        }
    }
}

- (void)saveLoginInformation:(void (^)(NSError *))completion
{
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *machine =[NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    LoginInformation *info = [LoginInformation new];
    info.time = [formatter stringFromDate:now];
    info.longitude = [NSNumber numberWithFloat:appDelegate.locationManager.location.coordinate.longitude];
    info.latitude = [NSNumber numberWithFloat:appDelegate.locationManager.location.coordinate.latitude];
    info.model = [self platformType:machine];
    info.os = [[UIDevice currentDevice] systemVersion];
    info.network = [carrier carrierName];
    info.phoneType = @"Apple";
    info.appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    
    [self authorize:^{
        NSDictionary *params = [MTLJSONAdapter JSONDictionaryFromModel:info];
        
        [self POST:@"api/LoginInformation" parameters:params completion:^(id response, NSError *error) {
            if (error == nil)
            {
                if (completion) {
                    completion(nil);
                }
            }
            else
            {
                if (completion) {
                    completion(error);
                }
            }
        }];
    }];
    
    [appDelegate.locationManager stopUpdatingLocation];
}

- (void)saveDeviceToken:(NSString *)token completion:(void (^)(NSError *))completion
{
    [self authorize:^{
        NSDictionary *params = @{
                                 @"token" : token
                                 };
        
        [self POST:@"api/User/APNSToken" parameters:params
           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
               if (completion) {
                   completion(nil);
               }
           } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
               NSLog(@"Failed to save device token - %@", error.description);
               
               if (completion) {
                   completion(error);
               }
           }];
    }];
}

- (void)getAppVersion:(void (^)(AppVersion *, NSError *))completion
{
    [self authorize:^{
        [self GET:@"api/AppVersion" parameters:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
              NSDictionary *result = ((OVCResponse *)responseObject).result;
              AppVersion *appVersion = [MTLJSONAdapter modelOfClass:[AppVersion class] fromJSONDictionary:result error:nil];
              
              if (completion) {
                  completion(appVersion, nil);
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (completion) {
                  completion(nil, error);
              }
          }];
    }];
}

- (void)getUser:(void (^)(User *, NSError *))completion
{
    [self authorize:^{
        [self GET:@"api/User" parameters:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
              NSDictionary *result = ((OVCResponse *)responseObject).result;
              User *user = [MTLJSONAdapter modelOfClass:[User class] fromJSONDictionary:result error:nil];
              
              if (completion) {
                  completion(user, nil);
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (completion) {
                  completion(nil, error);
              }
          }];
    }];
}

- (void)getBloodPressureMeasurements:(void (^)(NSMutableArray *, NSError *))completion
{
    [self authorize:^{
        [self GET:@"api/BloodPressure" parameters:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
              NSArray *results = [MTLJSONAdapter modelsOfClass:[BloodPressureMeasurement class] fromJSONArray:((OVCResponse *)responseObject).result error:nil];
              NSMutableArray *measurements = [NSMutableArray new];
              
              [measurements addObjectsFromArray:results];
              
              if (completion) {
                  completion(measurements, nil);
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Failed to get measurements - %@", error.description);
              
              if (completion) {
                  completion(nil, error);
              }
          }];
    }];
}

- (void)saveBloodPressureMeasurement:(BloodPressureMeasurement *)measurement completion:(void (^)(NSError *))completion
{
    [self authorize:^{
        NSDictionary *params = [MTLJSONAdapter JSONDictionaryFromModel:measurement];
        
        [self POST:@"api/BloodPressure" parameters:params
           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
               if (completion) {
                   completion(nil);
               }
           } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
               NSLog(@"Failed to save blood pressure - %@", error.description);
               
               if (completion) {
                   completion(error);
               }
           }];
    }];
}

- (void)getWeightMeasurements:(void (^)(NSMutableArray *, NSError *))completion
{
    [self authorize:^{
        [self GET:@"api/Weight" parameters:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
              NSArray *results = [MTLJSONAdapter modelsOfClass:[WeightMeasurement class] fromJSONArray:((OVCResponse *)responseObject).result error:nil];
              NSMutableArray *measurements = [NSMutableArray new];
              
              [measurements addObjectsFromArray:results];
              
              if (completion) {
                  completion(measurements, nil);
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Failed to get measurements - %@", error.description);
              
              if (completion) {
                  completion(nil, error);
              }
          }];
    }];
}

- (void)saveWeightMeasurement:(WeightMeasurement *)measurement completion:(void (^)(NSError *))completion
{
    [self authorize:^{
        NSDictionary *params = [MTLJSONAdapter JSONDictionaryFromModel:measurement];
        
        [self POST:@"api/Weight" parameters:params
           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
               if (completion) {
                   completion(nil);
               }
           } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
               if (completion) {
                   completion(error);
               }
           }];
    }];
}

- (void)getBloodGlucoseMeasurements:(void (^)(NSMutableArray *, NSError *))completion
{
    [self authorize:^{
        [self GET:@"api/BloodGlucose" parameters:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
              NSArray *results = [MTLJSONAdapter modelsOfClass:[BloodGlucoseMeasurement class] fromJSONArray:((OVCResponse *)responseObject).result error:nil];
              NSMutableArray *measurements = [NSMutableArray new];
              
              [measurements addObjectsFromArray:results];
              
              if (completion) {
                  completion(measurements, nil);
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Failed to get measurements - %@", error.description);
              
              if (completion) {
                  completion(nil, error);
              }
          }];
    }];
}

- (void)saveBloodGlucoseMeasurement:(BloodGlucoseMeasurement *)measurement completion:(void (^)(NSError *))completion
{
    [self authorize:^{
        NSDictionary *params = [MTLJSONAdapter JSONDictionaryFromModel:measurement];
        
        [self POST:@"api/BloodGlucose" parameters:params
           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
               if (completion) {
                   completion(nil);
               }
           } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
               if (completion) {
                   completion(error);
               }
           }];
    }];
}

- (void)getOxygenSaturation:(void (^)(NSMutableArray *, NSError *))completion
{
    [self authorize:^{
        [self GET:@"api/OxygenSaturation" parameters:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
              NSArray *results = [MTLJSONAdapter modelsOfClass:[OxygenSaturation class] fromJSONArray:((OVCResponse *)responseObject).result error:nil];
              NSMutableArray *measurements = [NSMutableArray new];
              
              [measurements addObjectsFromArray:results];
              
              if (completion) {
                  completion(measurements, nil);
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Failed to get measurements - %@", error.description);
              
              if (completion) {
                  completion(nil, error);
              }
          }];
    }];
}

- (void)saveOxygenSaturation:(OxygenSaturation *)measurement completion:(void (^)(NSError *))completion
{
    [self authorize:^{
        NSDictionary *params = [MTLJSONAdapter JSONDictionaryFromModel:measurement];
        
        [self POST:@"api/OxygenSaturation" parameters:params
           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
               if (completion) {
                   completion(nil);
               }
           } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
               NSLog(@"%@", error.description);
               
               if (completion) {
                   completion(error);
               }
           }];
    }];
}


- (void)savePillCapInstance:(PillCapInstance *)instance completion:(void (^)(NSError *))completion
{
    [self authorize:^{
        NSDictionary *params = [MTLJSONAdapter JSONDictionaryFromModel:instance];
        
        [self POST:@"api/PillCapInstance" parameters:params
           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
               if (completion) {
                   completion(nil);
               }
           } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
               if (completion) {
                   completion(error);
               }
           }];
    }];
}

- (void)getUserMedication:(NSNumber *)userMedicationId completion:(void (^)(UserMedication *, NSError *))completion
{
    [self authorize:^{
        [self GET:[NSString stringWithFormat:@"api/UserMedication/%d", userMedicationId.intValue] parameters:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
              UserMedication *medication = ((OVCResponse *)responseObject).result;
              
              if (completion) {
                  completion(medication, nil);
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              if (completion) {
                  completion(nil, error);
              }
          }];
    }];
}

- (void)getSurvey:(NSNumber *)surveyId completion:(void (^)(Survey *, NSError *))completion
{
    [self authorize:^{
        [self GET:[NSString stringWithFormat: @"api/Survey/%d", surveyId.intValue] parameters:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
              Survey *survey = ((OVCResponse *)responseObject).result;

              NSLog(@"Survey: %@", survey.name);
              
              if (completion) {
                  completion(survey, nil);
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Failed to get survey - %@", error.description);
              
              if (completion) {
                  completion(nil, error);
              }
          }];
    }];
}

- (void)getSurveyQuestion:(NSNumber *)surveyId completion:(void (^)(SurveyQuestion *, NSError *))completion
{
    [self authorize:^{
        [self GET:[NSString stringWithFormat: @"api/SurveyQuestion/%d", surveyId.intValue] parameters:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
              SurveyQuestion *surveyQuestion = ((OVCResponse *)responseObject).result;
              
              if (completion) {
                  completion(surveyQuestion, nil);
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Failed to get survey question - %@", error.description);
              
              if (completion) {
                  completion(nil, error);
              }
          }];
    }];
}

- (void)getSurveyQuestionOptions:(NSNumber *)questionId completion:(void (^)(NSMutableArray *, NSError *))completion
{
    [self authorize:^{
        [self GET:[NSString stringWithFormat: @"api/SurveyQuestionOptions/%d", questionId.intValue] parameters:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
              
              NSMutableArray *questionOptions = ((OVCResponse *)responseObject).result;
              
              if (completion) {
                  completion(questionOptions, nil);
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Failed to get question options - %@", error.description);
              
              if (completion) {
                  completion(nil, error);
              }
          }];
    }];
}

- (void)postSurveyAnswers:(NSMutableArray *)answers survey:(NSNumber *)surveyId question:(NSNumber *)questionId completion:(void (^)(NSError *))completion
{
    [self authorize:^{
        NSArray *params = [MTLJSONAdapter JSONArrayFromModels:answers];
                
        [self POST:[NSString stringWithFormat: @"api/SurveyAnswers/%d/%d", surveyId.intValue, questionId.intValue]parameters:params
           success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
               NSLog(@"Successfully Posted Survey Answers");
               if (completion) {
                   completion(nil);
               }
           } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
               NSLog(@"Failed to save survey answers - %@", error.description);
               
               if (completion) {
                   completion(error);
               }
           }];
    }];
}

- (void)postSurveyImage:(UIImage *)image survey:(NSNumber *)surveyId question:(NSNumber *)questionId completion:(void (^)(NSError *))completion
{
    [self authorize:^{
        NSData *imageData = UIImageJPEGRepresentation(image, 0.1);
        
        [self POST:[NSString stringWithFormat: @"api/SurveyImage/%d/%d", surveyId.intValue, questionId.intValue] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [formData appendPartWithFileData:imageData name:@"file" fileName:@"image.jpg" mimeType:@"image/jpeg"];
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
            NSLog(@"Successfully Posted Survey Image");
            if (completion) {
                completion(nil);
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            NSLog(@"Failed to save survey image - %@", error.description);
            
            if (completion) {
                completion(error);
            }
        }];
    }];
}

- (void)getImage:(NSString *)path completion:(void (^)(UIImage *, NSError *))completion
{
    [self authorize:^{
        [self.requestSerializer setValue:@"image/*" forHTTPHeaderField:@"Accept"];
        [self setResponseSerializer:[AFImageResponseSerializer serializer]];
        
        [self GET:[NSString stringWithFormat: @"Content/Images/%@", path] parameters:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
              
              UIImage *image = responseObject;
              
              if (completion) {
                  completion(image, nil);
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Failed to get image - %@", error.description);
              
              if (completion) {
                  completion(nil, error);
              }
          }];
    }];
}

- (void)getEnrollment:(void (^)(Enrollment *, NSError *))completion{
    [self authorize:^{
        [self GET:[NSString stringWithFormat: @"api/User/Enrollment"] parameters:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
              Enrollment *enrollment = ((OVCResponse *)responseObject).result;
              
              if (completion) {
                  completion(enrollment, nil);
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Failed to get enrollment - %@", error.description);
              
              if (completion) {
                  completion(nil, error);
              }
          }];
    }];
}

- (void)getActivationStatus:(void (^)(ActivationStatus *, NSError *))completion{
    [self authorize:^{
        [self GET:[NSString stringWithFormat: @"api/User/ActivationStatus"] parameters:nil
          success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
              ActivationStatus *activationStatus = ((OVCResponse *)responseObject).result;
              
              if (completion) {
                  completion(activationStatus, nil);
              }
          } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
              NSLog(@"Failed to get enrollment - %@", error.description);
              
              if (completion) {
                  completion(nil, error);
              }
          }];
    }];
}

- (void)registerUser:(NSString *)firstName lastName:(NSString *)lastName phoneNumber:(NSString *)phoneNumber email:(NSString *)email password:(NSString *)password confirmedPassword:(NSString *)confirmedPassword verificationCode: (NSString *)verificationCode mrn: (NSString *)mrn completion:(void (^)(NSError *))completion
{
    [self setRequestSerializer:httpRequestSerializer];
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [self.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    
    NSDictionary *params = @{
                             @"FirstName" : firstName ? firstName : @"",
                             @"LastName" : lastName ? lastName : @"",
                             @"PhoneNumber" : phoneNumber,
                             @"Email" : email,
                             @"Password" : password,
                             @"ConfirmPassword" : confirmedPassword,
                             @"VerificationCode" : verificationCode,
                             @"MRN" : mrn ? mrn : @""
                             };
    
    [self POST:@"api/Account/Register" parameters:params
       success:^(NSURLSessionDataTask * _Nonnull task, id  _Nonnull responseObject) {
           NSDictionary *result = ((OVCResponse *)responseObject).result;
           NSLog(@"This is the response: %@",result);
           
           if (completion) {
               completion(nil);
           }
       } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
           NSLog(@"Registration failed - %@", error.description);
           self.currentUser = nil;
           
           if (completion) {
               completion(error);
           }
       }];
}

- (NSString *)platformType:(NSString *)platform
{
    if ([platform isEqualToString:@"iPhone1,1"])    return @"iPhone 1G";
    if ([platform isEqualToString:@"iPhone1,2"])    return @"iPhone 3G";
    if ([platform isEqualToString:@"iPhone2,1"])    return @"iPhone 3GS";
    if ([platform isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([platform isEqualToString:@"iPhone3,3"])    return @"Verizon iPhone 4";
    if ([platform isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([platform isEqualToString:@"iPhone5,1"])    return @"iPhone 5 (GSM)";
    if ([platform isEqualToString:@"iPhone5,2"])    return @"iPhone 5 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone5,3"])    return @"iPhone 5c (GSM)";
    if ([platform isEqualToString:@"iPhone5,4"])    return @"iPhone 5c (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone6,1"])    return @"iPhone 5s (GSM)";
    if ([platform isEqualToString:@"iPhone6,2"])    return @"iPhone 5s (GSM+CDMA)";
    if ([platform isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([platform isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([platform isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([platform isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([platform isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([platform isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([platform isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([platform isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([platform isEqualToString:@"iPod5,1"])      return @"iPod Touch 5G";
    if ([platform isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([platform isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,2"])      return @"iPad 2 (GSM)";
    if ([platform isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([platform isEqualToString:@"iPad2,4"])      return @"iPad 2 (WiFi)";
    if ([platform isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([platform isEqualToString:@"iPad2,6"])      return @"iPad Mini (GSM)";
    if ([platform isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([platform isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad3,3"])      return @"iPad 3 (GSM)";
    if ([platform isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([platform isEqualToString:@"iPad3,5"])      return @"iPad 4 (GSM)";
    if ([platform isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([platform isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([platform isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([platform isEqualToString:@"iPad4,3"])      return @"iPad Air";
    if ([platform isEqualToString:@"iPad4,4"])      return @"iPad Mini 2G (WiFi)";
    if ([platform isEqualToString:@"iPad4,5"])      return @"iPad Mini 2G (Cellular)";
    if ([platform isEqualToString:@"iPad4,6"])      return @"iPad Mini 2G";
    if ([platform isEqualToString:@"iPad4,7"])      return @"iPad Mini 3 (WiFi)";
    if ([platform isEqualToString:@"iPad4,8"])      return @"iPad Mini 3 (Cellular)";
    if ([platform isEqualToString:@"iPad4,9"])      return @"iPad Mini 3 (China)";
    if ([platform isEqualToString:@"iPad5,3"])      return @"iPad Air 2 (WiFi)";
    if ([platform isEqualToString:@"iPad5,4"])      return @"iPad Air 2 (Cellular)";
    if ([platform isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2G";
    if ([platform isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3";
    if ([platform isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3 (2013)";
    if ([platform isEqualToString:@"i386"])         return @"Simulator";
    if ([platform isEqualToString:@"x86_64"])       return @"Simulator";
    return platform;
}

@end
