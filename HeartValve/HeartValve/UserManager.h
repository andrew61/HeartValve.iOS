//
//  UserManager.h
//  MyHealthApp
//
//  Created by Jonathan on 1/7/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <Overcoat/Overcoat.h>

#define kAuthenticationDidExpireNotification @"AuthenticationExpired"

@class User;
@class AppVersion;
@class BloodPressureMeasurement;
@class WeightMeasurement;
@class BloodGlucoseMeasurement;
@class OxygenSaturation;
@class PillCapInstance;
@class MedicationSchedule;
@class MedicationRefill;
@class MedicationAlert;
@class UserMedication;
@class Survey;
@class SurveyQuestion;
@class SurveyQuestionOptions;
@class SurveyAnswer;
@class Enrollment;
@class ActivationStatus;

@interface UserManager : OVCHTTPSessionManager

@property (strong, nonatomic) User *currentUser;

+ (UserManager *)sharedManager;
- (void)logIn:(NSString *)username password:(NSString *)password completion:(void (^)(User *currentUser, NSError *error))completion;
- (void)saveLoginInformation:(void (^)(NSError *error))completion;
- (void)saveDeviceToken:(NSString *)token completion:(void (^)(NSError *error))completion;
- (void)getAppVersion:(void (^)(AppVersion *appVersion, NSError *error))completion;
- (void)getUser:(void (^)(User *user, NSError *error))completion;
- (void)getBloodPressureMeasurements:(void (^)(NSMutableArray *measurements, NSError *error))completion;
- (void)saveBloodPressureMeasurement:(BloodPressureMeasurement *)measurement completion:(void (^)(NSError *error))completion;
- (void)getWeightMeasurements:(void (^)(NSMutableArray *measurements, NSError *error))completion;
- (void)saveWeightMeasurement:(WeightMeasurement *)measurement completion:(void (^)(NSError *error))completion;
- (void)getBloodGlucoseMeasurements:(void (^)(NSMutableArray *measurements, NSError *error))completion;
- (void)saveBloodGlucoseMeasurement:(BloodGlucoseMeasurement *)measurement completion:(void (^)(NSError *error))completion;
- (void)getOxygenSaturation:(void (^)(NSMutableArray *measurements, NSError *error))completion;
- (void)saveOxygenSaturation:(OxygenSaturation *)measurement completion:(void (^)(NSError *error))completion;
- (void)getPillCapInstances:(void (^)(NSMutableArray *instances, NSError *error))completion;
- (void)savePillCapInstance:(PillCapInstance *)instance completion:(void (^)(NSError *error))completion;
- (void)getUserMedication:(NSNumber *)userMedicationId completion:(void (^)(UserMedication *medication, NSError *error))completion;
- (void)getUserMedications:(void (^)(NSMutableArray *medications, NSError *error))completion;
- (void)saveUserMedication:(UserMedication *)medication completion:(void (^)(UserMedication *medication, NSError *error))completion;
- (void)deleteUserMedication:(UserMedication *)medication completion:(void (^)(NSError *error))completion;
- (void)getMedicationSchedules:(void (^)(NSMutableArray *schedules, NSError *error))completion;
- (void)saveMedicationSchedules:(NSMutableArray *)schedules completion:(void (^)(NSMutableArray *schedules, NSError *error))completion;
- (void)setMedicationSchedulesInactive:(NSMutableArray *)schedules inactive:(BOOL)inactive completion:(void (^)(NSError *error))completion;
- (void)deleteMedicationSchedules:(NSMutableArray *)schedules completion:(void (^)(NSError *error))completion;
- (void)getMedicationRefills:(NSNumber *)userMedicationId completion:(void (^)(NSMutableArray *refills, NSError *error))completion;
- (void)saveMedicationRefill:(MedicationRefill *)refill completion:(void (^)(NSError *error))completion;
- (void)getMedicationAlerts:(void (^)(NSMutableArray *alerts, NSError *error))completion;
- (void)getMedicationAlerts:(NSNumber *)groupId completion:(void (^)(NSMutableArray *alerts, NSError *error))completion;
- (void)saveMedicationAlerts:(NSMutableArray *)alerts completion:(void (^)(NSError *error))completion;
- (void)getMedications:(void (^)(NSMutableArray *medications, NSError *error))completion;
- (void)getMedicationUnits:(void (^)(NSMutableArray *units, NSError *error))completion;
- (void)getMedicationAlertTypes:(void (^)(NSMutableArray *alertTypes, NSError *error))completion;
- (void)getMedicationsNotTaken:(void (^)(NSMutableArray *medicationsNotTaken, NSError *error))completion;
- (void)getMedicationsAsNeeded:(void (^)(NSMutableArray *medicationsAsNeeded, NSError *error))completion;
- (void)saveMedicationActivity:(NSMutableArray *)activity completion:(void (^)(NSError *error))completion;
- (void)getMedicationAdherenceDetailsWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate completion:(void (^)(NSMutableArray *details, NSError *error))completion;
- (void)getMedicationDosageForms:(void (^)(NSMutableArray *dosageForms, NSError *error))completion;
- (void)getMedicationRoutes:(void (^)(NSMutableArray *routes, NSError *error))completion;

- (void)getSurvey:(NSNumber *)surveyId completion:(void (^)(Survey *survey, NSError *error))completion;
- (void)getSurveyQuestion:(NSNumber *)surveyId completion:(void (^)(SurveyQuestion *surveyQuestion, NSError *error))completion;
- (void)getSurveyQuestionOptions:(NSNumber *)questionId completion:(void (^)(NSMutableArray *questionOptions, NSError *error))completion;
- (void)postSurveyAnswers:(NSMutableArray *)answers survey:(NSNumber *)surveyId question:(NSNumber *)questionId completion:(void (^)(NSError *error))completion;
- (void)postSurveyImage:(UIImage *)image survey:(NSNumber *)surveyId question:(NSNumber *)questionId completion:(void (^)(NSError *error))completion;
- (void)getImage:(NSString *)path completion:(void (^)(UIImage *image, NSError *error))completion;
- (void)getEnrollment:(void (^)(Enrollment *enrollment, NSError *error))completion;
- (void)getActivationStatus:(void (^)(ActivationStatus *activationStatus, NSError *error))completion;
- (void)registerUser:(NSString *)firstName lastName:(NSString *)lastName phoneNumber:(NSString *)phoneNumber email:(NSString *)email password:(NSString *)password confirmedPassword:(NSString *)confirmedPassword verificationCode: (NSString *)verificationCode mrn: (NSString *)mrn completion:(void (^)(NSError *))completion;
@end
