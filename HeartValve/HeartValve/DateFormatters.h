//
//  DateFormatters.h
//  MyHealthApp
//
//  Created by Jonathan on 2/8/16.
//  Copyright © 2016 MUSC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DateFormatters : NSObject

+ (NSDateFormatter *)sendJSONDateFormatter;
+ (NSDateFormatter *)receiveJSONDateFormatter;
+ (NSDateFormatter *)timeFormatter;
+ (NSDateFormatter *)time24Formatter;
+ (NSDateFormatter *)dateTimeFormatter;
+ (NSDateFormatter *)dateTime24Formatter;
+ (NSDateFormatter *)shortDateFormatter;
+ (NSDateFormatter *)longDateFormatter;
+ (NSDateFormatter *)longDateTimeFormatter;
+ (NSDateFormatter *)extendedDateFormatter;

@end