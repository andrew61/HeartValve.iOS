//
//  DateFormatters.m
//  MyHealthApp
//
//  Created by Jonathan on 2/8/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import "DateFormatters.h"

@implementation DateFormatters

+ (NSDateFormatter *)sendJSONDateFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return formatter;
}

+ (NSDateFormatter *)receiveJSONDateFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
    return formatter;
}

+ (NSDateFormatter *)timeFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"h:mm a";
    return formatter;
}

+ (NSDateFormatter *)time24Formatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"k:mm:ss";
    return formatter;
}

+ (NSDateFormatter *)dateTimeFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return formatter;
}

+ (NSDateFormatter *)dateTime24Formatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd k:mm:ss";
    return formatter;
}

+ (NSDateFormatter *)shortDateFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"M/d";
    return formatter;
}

+ (NSDateFormatter *)longDateFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MM/dd/yyyy";
    return formatter;
}

+ (NSDateFormatter *)longDateTimeFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM d h:mm a";
    return formatter;
}

+ (NSDateFormatter *)extendedDateFormatter
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMM d, yyyy";
    return formatter;
}

@end