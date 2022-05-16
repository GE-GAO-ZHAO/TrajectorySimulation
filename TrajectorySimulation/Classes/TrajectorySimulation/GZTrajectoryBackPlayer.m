//
//  GZTrajectoryBackPlayer.m
//  front-mathcing-iOS
//
//  Created by 葛高召 on 2022/3/5.
//

#import "GZTrajectoryBackPlayer.h"
#import "GZFileTool.h"
#import "GZWeakProxy.h"
#import "NSObject+GZYYModel.h"
#import "GZTrajectorySimulationMiddieware.h"
#import "GZLocation.h"
@interface GZTrajectoryBackPlayer() 
@property (nonatomic, strong) GZWeakProxy *weakProxy;
@property (nonatomic, strong) NSTimer      *playerTimer;
@property (nonatomic, strong) NSMutableArray<GZLocation *> *gpsLocations;
@property (nonatomic, strong) GZTrajectorySimulationMiddieware *broadcastGpsMiddieware;

@end

@implementation GZTrajectoryBackPlayer


#pragma mark --
#pragma mark -- life cycle

- (instancetype)init {
    if (self = [super init]) {
        _broadcastGpsMiddieware = [[GZTrajectorySimulationMiddieware alloc] init];
        [self redayData];
    }
    return self;
}

#pragma mark --
#pragma mark -- api

- (void)playbackGpsWithFrequency:(NSInteger)frequency {
    [_broadcastGpsMiddieware startMockPoint];
    _weakProxy = [GZWeakProxy alloc];
    _weakProxy.target = self;
    _playerTimer = [NSTimer timerWithTimeInterval:frequency
                                           target:self.weakProxy
                                         selector:@selector(broadcastGps)
                                         userInfo:nil
                                          repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:_playerTimer forMode:NSRunLoopCommonModes];
}

- (void)pause {
    [_playerTimer setFireDate:[NSDate distantFuture]];
}
- (void)play {
    [_playerTimer setFireDate:[NSDate date]];
}

- (void)stopPlaybackGps {
    if (_playerTimer.isValid) {  [_playerTimer invalidate]; }
    [_broadcastGpsMiddieware stopMockPoint];
}

#pragma mark --
#pragma mark --

- (void)broadcastGps {
    if (0 == [self.gpsLocations count]) {
        [_playerTimer invalidate];
        return;
    }
    GZLocation *location = [self.gpsLocations firstObject];
    [self.gpsLocations removeObjectAtIndex:0];
    [_broadcastGpsMiddieware mockPoint:location];
}

#pragma mark --
#pragma mark -- file

- (void)redayData {
    _gpsLocations = [[NSMutableArray alloc] init];
    BOOL exist = [[GZFileTool shareInstence] fileExistsAtPath:gpsFilePath];
    NSData *data = nil;
    if (exist) {
        data = [[GZFileTool shareInstence] readDataWithFilePath:gpsFilePath];
    } else {
        NSURL *associateBundleURL = [[NSBundle mainBundle] URLForResource:@"GpsInfoResource" withExtension:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithURL:associateBundleURL];
        NSString *trackPath = [bundle pathForResource:@"gps_record" ofType:@"txt"];
        data = [[NSData alloc] initWithContentsOfFile:trackPath];
    }
    NSString *gpsStrong = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray <NSString *>*array = [gpsStrong componentsSeparatedByString:@"!FF"];
    [array enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj && [obj length] > 0) {
            GZLocation *location = [GZLocation GZYY_modelWithJSON:obj];
            if (location) {
                [self.gpsLocations addObject:location];
            }
        }
    }];
}

@end
