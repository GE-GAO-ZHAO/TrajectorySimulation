//
//  GZDateTool.m
//  front-mathcing-iOS
//
//  Created by 葛高召 on 2021/11/5.
//

#import "GZDateTool.h"

@implementation GZDateTool

+ (NSTimeInterval)getNowTimeTimestamp {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"];
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    [formatter setTimeZone:timeZone];
    NSDate *datenow = [NSDate date];
    return [datenow timeIntervalSince1970]*1000;
}

+ (NSString *)currentCalendar {
    NSDate  *currentDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:currentDate];
    NSInteger year = [components year];
    NSInteger month = [components month];
    NSInteger day = [components day];
    return [NSString stringWithFormat:@"%ld-%ld-%ld",year,month,day];
}

+ (NSString *)currentDateStrWithDateFormat:(NSString *)dateFormat {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:(dateFormat && dateFormat.length > 0 ? dateFormat : @"YYYY-MM-dd HH:mm:ss SSS")];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    return dateString;
}

+ (NSTimeInterval)durationWithStarTime:(NSString *)starTime andInsertEndTime:(NSString *)endTime {
    NSDateFormatter* formater = [[NSDateFormatter alloc] init];
    [formater setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"];
    NSDate* startDate = [formater dateFromString:starTime];
    NSDate* endDate = [formater dateFromString:endTime];
    double date1 = [startDate timeIntervalSince1970];
    double date2 = [endDate timeIntervalSince1970];
    NSTimeInterval duration = date2 - date1;
    return duration;
}

+ (NSString *)durationWithStarTime:(NSString *)starTime endTime:(NSString *)endTime {
    // 1.将时间转换为date
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"YYYY-MM-dd HH:mm:ss SSS";
    NSDate *date1 = [formatter dateFromString:starTime];
    NSDate *date2 = [formatter dateFromString:endTime];
    // 2.创建日历
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSCalendarUnit type = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    // 3.利用日历对象比较两个时间的差值
    NSDateComponents *cmps = [calendar components:type fromDate:date1 toDate:date2 options:0];
    // 4.输出结果
    NSString *result= @"两个时间相差";
    NSString *duration = @"";
    if (cmps.year > 0 ) {
        duration = [duration stringByAppendingString:[NSString stringWithFormat:@"%ld年",cmps.year]];
    }
    if (cmps.month > 0 ) {
        duration = [duration stringByAppendingString:[NSString stringWithFormat:@"%ld月",cmps.month]];
    }
    if (cmps.day > 0 ) {
        duration = [duration stringByAppendingString:[NSString stringWithFormat:@"%ld日",cmps.day]];
    }
    if (cmps.hour > 0 ) {
        duration = [duration stringByAppendingString:[NSString stringWithFormat:@"%ld小时",cmps.hour]];
    }
    if (cmps.minute > 0 ) {
        duration = [duration stringByAppendingString:[NSString stringWithFormat:@"%ld分钟",cmps.minute]];
    }
    if (cmps.second > 0 ) {
        duration = [duration stringByAppendingString:[NSString stringWithFormat:@"%ld秒",cmps.second]];
    }
    if (duration.length <= 0) {
        result = [result stringByAppendingString:@"00小时00分钟00秒"];
    }
    return result;
}

+ (NSDate *)nsstringConversionNSDate:(NSString *)dateStr {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"];
    NSDate *datestr = [dateFormatter dateFromString:dateStr];
    return datestr;
}

+ (NSString *)dateConversionTimeStamp:(NSDate *)date {
    NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[date timeIntervalSince1970]*1000];
    return timeSp;
}

@end
