//
//  GZExtanalNaviGpsCollector.h
//  GZBusinessKit
//
//  Created by 葛高召 on 2021/11/3.
//  Copyright © 2021 com.TrajectorySimulation.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLGeocoder.h>


@protocol GZGpsCollectorProtocol <NSObject>

- (void)locationUpdateSuccessWith:(CLLocation*)location;

@end

NS_ASSUME_NONNULL_BEGIN

/// @class 外置导航获取gps专用，目前只要距离变化就会回调
@interface GZGpsCollector : NSObject
/// 最近一次获取的位置(包含详细信息)
@property (nonatomic,strong) CLLocation *latestLocation;
/// 定位服务未开启的操作
@property (nonatomic, copy) void (^locationServicesClosed)(void);
/// 定位权限被拒绝的操作
@property (nonatomic, copy) void (^authorizationStatusDenied)(void);
/// 定位成功的位置回调
@property (nonatomic, copy) void (^locationUpdateSuccess)(NSArray<CLLocation*>* locations);
/// 定位失败的信息回调
@property (nonatomic, copy) void (^locationUpdateFailed)(NSError* error);
/// 定位权限更改的回调，无权限时默认已调用了authorizationStatusDeniedBlock
@property (nonatomic, copy) void (^locationDidChangeAuthorization)(CLAuthorizationStatus status);


+ (instancetype)sharedInstance;
+ (void)destory;

/// @brief 开始定位服务, locationUpdateSuccess 必须传才可以接受结果❗️
- (void)startLocationService;
/// @brief 结束定位服务
- (void)endLocationService;
/// @brief 货拉拉的定位服务已打开
- (BOOL)locationEnabled;

- (void)addLocationListener:(id <GZGpsCollectorProtocol>)listener;
- (void)removeLocationListener:(id <GZGpsCollectorProtocol>)listener;

@end

NS_ASSUME_NONNULL_END
