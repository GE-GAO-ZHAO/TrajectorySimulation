//
//  GZRecordGPSLocationsManager.m
//  front-mathcing-iOS
//
//  Created by 葛高召 on 2022/2/5.
//

#import "GZTrajectoryPlaybackManager.h"
#import "GZFileTool.h"
#import "GZDateTool.h"
#import "GZTajectoryRecorder.h"
#import "GZTrajectoryBackPlayer.h"

@interface GZTrajectoryPlaybackManager()

@property (nonatomic, strong) id<GZTrajectorySimulationProtocol> performer;

@property (nonatomic, assign) GZTrajectoryPlaybackStatus trajectoryPlaybackStatus;

@end

@implementation GZTrajectoryPlaybackManager

#pragma mark --
#pragma mark -- life cycle methods

static GZTrajectoryPlaybackManager *shared;
static dispatch_once_t onceToken;
+ (instancetype)sharedInstance {
    dispatch_once(&onceToken, ^{
        shared = [[super allocWithZone:NULL] init];
        shared.trajectoryPlaybackStatus = GZTrajectoryPlaybackStatusDefault;
    });
    return shared;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone{
    return [self sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone{
    return self;
}

+ (void)destory {
    if (shared) {
        shared = nil;
        onceToken = 0l;
    }
}

#pragma mark --
#pragma mark -- api methods

- (BOOL)playbackGPSEnable {
    return NO;
}

- (GZTrajectoryPlaybackStatus)currentWorkStatus; {
    return GZTrajectoryPlaybackStatusDefault;
}

- (void)startRecordGPSWithComplate:(void (^)(BOOL, NSString * _Nonnull))complate {
    if (self.performer && self.trajectoryPlaybackStatus == GZTrajectoryPlaybackStatusPlaybackGps) {
        !complate ?: complate(NO,@"当前状态正处于轨迹回放中，不允许开启录制！");
        return;
    }
    if (self.trajectoryPlaybackStatus == GZTrajectoryPlaybackStatusRecordGps) {
        !complate ?: complate(NO,@"当前状态已正在轨迹录制中，不允许重复开启轨迹录制！");
        return;
    }
    self.trajectoryPlaybackStatus = GZTrajectoryPlaybackStatusRecordGps;
    self.performer = [[GZTajectoryRecorder alloc] init];
    [self.performer startRecordGPS];
    !complate ?: complate(NO,nil);
}

- (void)stopRecordGPSWithComplate:(void (^)(BOOL, NSString * _Nonnull))complate {
    if (self.trajectoryPlaybackStatus != GZTrajectoryPlaybackStatusRecordGps) {
        !complate ?: complate(NO,@"当前状态非处于轨迹录制中，不允许关闭录制！");
        return;
    }
    [self.performer stopRecordGPS];
    self.performer = nil;
    self.trajectoryPlaybackStatus = GZTrajectoryPlaybackStatusDefault;
    !complate ?: complate(NO,nil);
}

- (void)playbackGpsWithComplate:(void (^)(BOOL, NSString * _Nonnull))complate {
    if (self.performer && self.trajectoryPlaybackStatus == GZTrajectoryPlaybackStatusRecordGps) {
        !complate ?: complate(NO,@"当前状态正处于轨迹录制中，不允许开启轨迹回放！");
        return;
    }
    if (self.trajectoryPlaybackStatus == GZTrajectoryPlaybackStatusPlaybackGps) {
        !complate ?: complate(NO,@"当前状态已正在轨迹回放中，不允许重复开启轨迹回放！");
        return;
    }
    self.trajectoryPlaybackStatus = GZTrajectoryPlaybackStatusPlaybackGps;
    self.performer = [[GZTrajectoryBackPlayer alloc] init];
    [self.performer playbackGpsWithFrequency:1];
    !complate ?: complate(NO,nil);
}

- (void)stopPlaybackGpsWithComplate:(void (^)(BOOL, NSString * _Nonnull))complate {
    if (self.trajectoryPlaybackStatus != GZTrajectoryPlaybackStatusPlaybackGps) {
        !complate ?: complate(NO,@"当前状态非处于轨迹回放中，不允许关闭轨迹回放！");
        return;
    }
    self.trajectoryPlaybackStatus = GZTrajectoryPlaybackStatusDefault;
    [self.performer stopPlaybackGps];
    !complate ?: complate(NO,nil);
}

@end
