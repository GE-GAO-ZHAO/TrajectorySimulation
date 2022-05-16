//
//  GZDateTool.h
//  front-mathcing-iOS
//
//  Created by 葛高召 on 2021/11/5.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GZDateTool : NSObject
+ (NSTimeInterval)getNowTimeTimestamp;
+ (NSString *)currentCalendar;
+ (NSString *)currentDateStrWithDateFormat:(NSString *)dateFormat;
+ (NSTimeInterval)durationWithStarTime:(NSString *)starTime andInsertEndTime:(NSString *)endTime;
+ (NSString *)durationWithStarTime:(NSString *)starTime endTime:(NSString *)endTime;
+ (NSDate *)nsstringConversionNSDate:(NSString *)dateStr;
+ (NSString *)dateConversionTimeStamp:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
