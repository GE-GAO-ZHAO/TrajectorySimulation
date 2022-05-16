//
//  GZRecordGPSLocationsManager.h
//  front-mathcing-iOS
//
//  Created by 葛高召 on 2022/2/5.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLGeocoder.h>
NS_ASSUME_NONNULL_BEGIN

///@Enum 记录gps 和 重放gps 同一时间只能存在一种
typedef enum : NSUInteger {
    GZTrajectoryPlaybackStatusDefault       = 0,
    GZTrajectoryPlaybackStatusRecordGps     = 1,
    GZTrajectoryPlaybackStatusPlaybackGps   = 2
} GZTrajectoryPlaybackStatus;

///@Class 管理轨迹回放
@interface GZTrajectoryPlaybackManager : NSObject

+ (instancetype)sharedInstance;
+ (void)destory;

- (BOOL)playbackGPSEnable;
- (GZTrajectoryPlaybackStatus)currentWorkStatus;

- (void)startRecordGPSWithComplate:(void(^)(BOOL sucess, NSString *msg))complate;
- (void)stopRecordGPSWithComplate:(void(^)(BOOL sucess, NSString *msg))complate;

- (void)playbackGpsWithComplate:(void(^)(BOOL sucess, NSString *msg))complate;
- (void)stopPlaybackGpsWithComplate:(void(^)(BOOL sucess, NSString *msg))complate;

@end

NS_ASSUME_NONNULL_END
