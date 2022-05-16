//
//  GZExtanalNaviGpsCollector.m
//  GZBusinessKit
//
//  Created by 葛高召 on 2021/11/3.
//  Copyright © 2021 com.TrajectorySimulation.cn. All rights reserved.
//

#import "GZGpsCollector.h"
#import <libkern/OSAtomic.h>

@interface GZGpsCollector()<CLLocationManagerDelegate>

/// 如果用户拒绝定位时,用于判断第一次进入应用block会调两次的的解决方案
@property(nonatomic,assign) BOOL isDenied;

/// 是否正常采集中，YES:正常采集中；NO:关闭采集状态 , 默认NO
@property(nonatomic,assign) BOOL normalCollect;

/// 系统gps定位管理者
@property (nonatomic, strong) CLLocationManager *locationManager;

/// 监听者容器
@property(nonatomic,strong) NSHashTable <id <GZGpsCollectorProtocol>> *listenerHashTable;


@end

@implementation GZGpsCollector

#pragma mark --
#pragma mark -- life cycle

static GZGpsCollector *shared;
static dispatch_once_t onceToken;

+ (instancetype)sharedInstance {
    dispatch_once(&onceToken, ^{
        shared = [[super allocWithZone:NULL] init];
        shared.normalCollect = NO;
        shared.listenerHashTable = [NSHashTable hashTableWithOptions:NSPointerFunctionsWeakMemory];
        [shared moniteDetectionAppStatus];
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
        [shared endLocationService];
        shared = nil;
        onceToken = 0l;
    }
}

- (void)dealloc {
    NSLog(@"====GZGpsCollector dealloc====");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark --
#pragma mark -- Location Authentication

- (void)locationAuthentication {
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"用户没有授权开启定位服务");
        if (_locationServicesClosed) {
            _locationServicesClosed();
        }
    } else {
        NSLog(@"重新设置启定位服务");
        [self.locationManager stopUpdatingLocation];
        CLAuthorizationStatus status = [CLLocationManager authorizationStatus];
        NSLog(@"用户当前的定位授权状态：%d",status);
        switch (status) {
            case kCLAuthorizationStatusDenied:
            case kCLAuthorizationStatusRestricted: {
                NSLog(@"用户已明确拒绝此应用程序的授权，或位置服务在设置中被禁用或者系统强制不允许定位");
                if (_authorizationStatusDenied) {
                    _authorizationStatusDenied();
                }
                _isDenied = YES;
            }
                break;
            case kCLAuthorizationStatusNotDetermined: {
                NSLog(@"用户还没有就这个应用做出选择");
                UIApplicationState state = [UIApplication sharedApplication].applicationState;
                if(state == UIApplicationStateBackground) {
                    [self.locationManager requestAlwaysAuthorization];
                } else  {
                    [self.locationManager requestWhenInUseAuthorization];
                }
            }
                break;
            default: {
                NSLog(@"用户已授权改应用程序的定位授权，直接开启定位监听");
                _isDenied = NO;
                [self excuteStartLocation];
            }
                break;
        }
    }
}

#pragma mark --
#pragma mark -- API

- (void)addLocationListener:(id <GZGpsCollectorProtocol>)listener {
    if (![_listenerHashTable containsObject:listener]) {
        [_listenerHashTable addObject:listener];
    }
}

- (void)removeLocationListener:(id <GZGpsCollectorProtocol>)listener {
    if ([_listenerHashTable containsObject:listener]) {
        [_listenerHashTable removeObject:listener];
    }
}

- (void)listenerWithComplate:(void(^)(id<GZGpsCollectorProtocol> listener))complate {
    NSEnumerator *enumerator = [self.listenerHashTable objectEnumerator];
    id<GZGpsCollectorProtocol> listener;
    while (listener = [enumerator nextObject]) {
        if (complate) {
            complate(listener);
        }
    }
}

- (void)startLocationService {
    self.normalCollect = YES;
    [self locationAuthentication];
}

- (void)endLocationService {
    self.normalCollect = NO;
    if (self.locationUpdateSuccess) { _locationUpdateSuccess = nil; }
    [self.locationManager stopUpdatingLocation];
}

- (BOOL)locationEnabled {
    BOOL enabled = NO;
    if (self.normalCollect && [CLLocationManager locationServicesEnabled] &&
        ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse ||
         [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)) {
        enabled = YES;
    }
    return enabled;
}

#pragma mark --
#pragma mark -- Private methods

- (void)excuteStartLocation {
    [self.locationManager startUpdatingLocation];
}

#pragma mark --
#pragma mark -- monitor app`s activities

- (void)moniteDetectionAppStatus {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectAppEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(detectAppEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)detectAppEnterBackground {
    [_locationManager requestAlwaysAuthorization];
    _locationManager.pausesLocationUpdatesAutomatically = NO;
    if (@available(iOS 9.0, *)) {
        _locationManager.allowsBackgroundLocationUpdates = YES;
    }
}

- (void)detectAppEnterForeground {
    [_locationManager requestWhenInUseAuthorization];
    _locationManager.pausesLocationUpdatesAutomatically = YES;
}

#pragma mark --
#pragma mark --  CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    switch (status) {
        case kCLAuthorizationStatusDenied:
        case kCLAuthorizationStatusRestricted:
        {
            _isDenied = YES;
            if (!_isDenied && _authorizationStatusDenied) {
                _authorizationStatusDenied();
            }
        }
            break;
        default:
            _isDenied = NO;
            [self excuteStartLocation];
            break;
    }
}
/// 为了兼容iOS7,调用此方法获取位置
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    if (locations && locations.count >0) {
        CLLocation* location = [locations firstObject];
        NSLog(@"系统gps点回调>lon:%.6f,lat:%.6f",location.coordinate.longitude,location.coordinate.latitude);
        self.latestLocation = location;
        [self listenerWithComplate:^(id<GZGpsCollectorProtocol> listener) {
            if (listener && [listener respondsToSelector:@selector(locationUpdateSuccessWith:)]) {
                [listener locationUpdateSuccessWith:self.latestLocation];
            } else {
                NSLog(@"系统gps点回调/分发失败 原因：gps监听者为空或者没实现<locationUpdateSuccessWith>");
            }
        }];
        if (self.locationUpdateSuccess) {
            self.locationUpdateSuccess(locations);
        }
    }
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (_locationUpdateFailed) {
        _locationUpdateFailed(error);
    }
}

#pragma mark --
#pragma mark -- getter methods

- (CLLocationManager *)locationManager {
    if (!_locationManager) {
        _locationManager = [CLLocationManager new];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = kCLDistanceFilterNone;
    }
    return _locationManager;
}


@end
