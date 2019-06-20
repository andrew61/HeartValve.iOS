//
//  DbManager.m
//  MyHealthApp
//
//  Created by Jonathan on 1/30/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "DbManager.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "BloodPressureMeasurement.h"
#import "BloodGlucoseMeasurement.h"
#import "WeightMeasurement.h"
#import "OxygenSaturation.h"

@interface DbManager ()

@property (strong, nonatomic) NSString *documentsDirectory;
@property (strong, nonatomic) NSString *databasePath;

- (void)copyDatabaseIntoDocumentsDirectory;

@end

@implementation DbManager

+ (DbManager *)sharedManager
{
    static DbManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (id)init
{
    if (self = [super init]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        
        self.documentsDirectory = [paths objectAtIndex:0];
        self.databasePath = [self.documentsDirectory stringByAppendingPathComponent:DATABASE_FILENAME];
        
        [self copyDatabaseIntoDocumentsDirectory];
    }
    return self;
}

- (void)copyDatabaseIntoDocumentsDirectory
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.databasePath]) {
        NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DATABASE_FILENAME];
        NSError *error;
        
        [[NSFileManager defaultManager] copyItemAtPath:sourcePath toPath:self.databasePath error:&error];
        
        if (error != nil) {
            NSLog(@"%@", [error localizedDescription]);
        }
    }
}

- (void)upgrade
{
    NSString *sourcePath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DATABASE_FILENAME];
    FMDatabase *sourceDb = [FMDatabase databaseWithPath:sourcePath];
    FMDatabase *destinationDb = [FMDatabase databaseWithPath:self.databasePath];
    [sourceDb open];
    [destinationDb open];
    int sourceVersion = [sourceDb userVersion];
    int destinationVersion = [destinationDb userVersion];
    [sourceDb close];
    
    if (sourceVersion > destinationVersion)
    {
        for (int i = destinationVersion + 1; i <= sourceVersion; i++)
        {
            if (i == 2)
            {
                [destinationDb executeUpdate:@"CREATE TABLE IF NOT EXISTS OxygenSaturation (Id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL, SpO2 DOUBLE NOT NULL, HeartRate INTEGER NOT NULL, ReadingDate DATE NOT NULL)"];
            }
        }
        
        [destinationDb setUserVersion:sourceVersion];
    }
    
    [destinationDb close];
}

- (BOOL)insertBloodPressureMeasurement:(BloodPressureMeasurement *)measurement
{
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    
    [db open];
    
    BOOL success = [db executeUpdate:@"INSERT INTO BloodPressure VALUES (?,?,?,?,?,?)",
                    measurement.bloodPressureId, measurement.systolic, measurement.diastolic, measurement.map, measurement.pulse, measurement.readingDate];
    
    [db close];
    
    return success;
}

- (BOOL)insertBloodGlucoseMeasurement:(BloodGlucoseMeasurement *)measurement
{
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    
    [db open];
    
    BOOL success = [db executeUpdate:@"INSERT INTO BloodGlucose VALUES (?,?,?)",
                    measurement.bloodGlucoseId, measurement.glucoseLevel, measurement.readingDate];
    
    [db close];
    
    return success;
}

- (BOOL)insertWeightMeasurement:(WeightMeasurement *)measurement
{
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    
    [db open];
    
    BOOL success = [db executeUpdate:@"INSERT INTO Weight VALUES (?,?,?)",
                    measurement.weightId, measurement.weight, measurement.readingDate];
    
    [db close];
    
    return success;
}

- (BOOL)insertOxygenSaturation:(OxygenSaturation *)measurement
{
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    
    [db open];
    
    BOOL success = [db executeUpdate:@"INSERT INTO OxygenSaturation VALUES (?,?,?,?)",
                    measurement.oxygenSaturationId, measurement.spO2, measurement.heartRate, measurement.readingDate];
    
    [db close];
    
    return success;
}

- (BOOL)deleteBloodPressureMeasurement:(BloodPressureMeasurement *)measurement
{
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    
    [db open];
    
    BOOL success = [db executeUpdate:@"DELETE FROM BloodPressure WHERE Id=?", measurement.bloodPressureId];
    
    [db close];
    
    return success;
}

- (BOOL)deleteBloodGlucoseMeasurement:(BloodGlucoseMeasurement *)measurement
{
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    
    [db open];
    
    BOOL success = [db executeUpdate:@"DELETE FROM BloodGlucose WHERE Id=?", measurement.bloodGlucoseId];
    
    [db close];
    
    return success;
}

- (BOOL)deleteWeightMeasurement:(WeightMeasurement *)measurement
{
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    
    [db open];
    
    BOOL success = [db executeUpdate:@"DELETE FROM Weight WHERE Id=?", measurement.weightId];
    
    [db close];
    
    return success;
}

- (BOOL)deleteOxygenSaturation:(OxygenSaturation *)measurement
{
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    
    [db open];
    
    BOOL success = [db executeUpdate:@"DELETE FROM OxygenSaturation WHERE Id=?", measurement.oxygenSaturationId];
    
    [db close];
    
    return success;
}

- (NSMutableArray *)getBloodPressureMeasurements
{
    NSMutableArray *measurements = [[NSMutableArray alloc] init];
    
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    
    [db open];
    
    FMResultSet *results;
    
    results = [db executeQuery:@"SELECT * FROM BloodPressure"];
    
    while ([results next])
    {
        BloodPressureMeasurement *measurement = [BloodPressureMeasurement new];
        
        measurement.bloodPressureId = [NSNumber numberWithInt:[results intForColumn:@"Id"]];
        measurement.systolic = [NSNumber numberWithInt:[results intForColumn:@"Systolic"]];
        measurement.diastolic = [NSNumber numberWithInt:[results intForColumn:@"Diastolic"]];
        measurement.map = [NSNumber numberWithInt:[results intForColumn:@"Map"]];
        measurement.pulse = [NSNumber numberWithInt:[results intForColumn:@"Pulse"]];
        measurement.readingDate = [results dateForColumn:@"ReadingDate"];
        
        [measurements addObject:measurement];
    }
    
    [db close];
    
    return measurements;
}

- (NSMutableArray *)getBloodGlucoseMeasurements
{
    NSMutableArray *measurements = [[NSMutableArray alloc] init];
    
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    
    [db open];
    
    FMResultSet *results;
    
    results = [db executeQuery:@"SELECT * FROM BloodGlucose"];
    
    while ([results next])
    {
        BloodGlucoseMeasurement *measurement = [BloodGlucoseMeasurement new];
        
        measurement.bloodGlucoseId = [NSNumber numberWithInt:[results intForColumn:@"Id"]];
        measurement.glucoseLevel = [NSNumber numberWithInt:[results intForColumn:@"GlucoseLevel"]];
        measurement.readingDate = [results dateForColumn:@"ReadingDate"];
        
        [measurements addObject:measurement];
    }
    
    [db close];
    
    return measurements;
}

- (NSMutableArray *)getWeightMeasurements
{
    NSMutableArray *measurements = [[NSMutableArray alloc] init];
    
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    
    [db open];
    
    FMResultSet *results;
    
    results = [db executeQuery:@"SELECT * FROM Weight"];
    
    while ([results next])
    {
        WeightMeasurement *measurement = [WeightMeasurement new];
        
        measurement.weightId = [NSNumber numberWithInt:[results intForColumn:@"Id"]];
        measurement.weight = [NSNumber numberWithDouble:[results doubleForColumn:@"Weight"]];
        measurement.readingDate = [results dateForColumn:@"ReadingDate"];
        
        [measurements addObject:measurement];
    }
    
    [db close];
    
    return measurements;
}

- (NSMutableArray *)getOxygenSaturation
{
    NSMutableArray *measurements = [[NSMutableArray alloc] init];
    
    FMDatabase *db = [FMDatabase databaseWithPath:self.databasePath];
    
    [db open];
    
    FMResultSet *results;
    
    results = [db executeQuery:@"SELECT * FROM OxygenSaturation"];
    
    while ([results next])
    {
        OxygenSaturation *measurement = [OxygenSaturation new];
        
        measurement.oxygenSaturationId = [NSNumber numberWithInt:[results intForColumn:@"Id"]];
        measurement.spO2 = [NSNumber numberWithDouble:[results doubleForColumn:@"SpO2"]];
        measurement.heartRate = [NSNumber numberWithInt:[results intForColumn:@"HeartRate"]];
        measurement.readingDate = [results dateForColumn:@"ReadingDate"];
        
        [measurements addObject:measurement];
    }
    
    [db close];
    
    return measurements;
}

@end
