//
//  GZTrajectorySimulationMiddieware.m
//  front-mathcing-iOS
//
//  Created by 葛高召 on 2022/3/6.
//

#import "GZTrajectorySimulationMiddieware.h"
#import "GZWeakProxy.h"
#import <CoreLocation/CoreLocation.h>
#import "GZTrajectorySimulationMiddieware.h"
#import "NSObject+MethodSwizzle.h"
#import "CLLocationManager+SimulationLocation.h"

@interface GZTrajectorySimulationMiddieware()<CLLocationManagerDelegate>


@property (nonatomic, assign, getter=isMocking)     BOOL mocking;
@property (nonatomic, strong) NSMapTable                *locationMonitor;
@property (nonatomic, strong) CLLocation                *oldLocation;
@property (nonatomic, strong) CLLocation                *pointLocation;
@property (nonatomic, strong) NSTimer                   *simTimer;
@property (nonatomic, strong) GZWeakProxy              *weakProxy;

@end

static dispatch_once_t once;
static GZTrajectorySimulationMiddieware *instance;

@implementation GZTrajectorySimulationMiddieware

+ (void)load {
#if DEBUG
    [[GZTrajectorySimulationMiddieware shareInstance] swizzleCLLocationMangagerDelegate];
#endif
}

+ (GZTrajectorySimulationMiddieware *)shareInstance{
    dispatch_once(&once, ^{
        instance = [[GZTrajectorySimulationMiddieware alloc] init];
        instance.locationMonitor = [NSMapTable strongToWeakObjectsMapTable];
    });
    return instance;
}

- (void)destory {
    instance = nil;
    once = 0l;
}

- (void)addLocationBinder:(id)binder delegate:(id)delegate{
    NSString *binderKey = [NSString stringWithFormat:@"%p_binder",binder];
    NSString *delegateKey = [NSString stringWithFormat:@"%p_delegate",binder];
    [instance.locationMonitor setObject:binder forKey:binderKey];
    [instance.locationMonitor setObject:delegate forKey:delegateKey];
}

- (void)swizzleCLLocationMangagerDelegate {
    [[CLLocationManager class] gz_swizzleInstanceMethodWithOriginSel:@selector(setDelegate:) swizzledSel:@selector(gz_swizzleLocationDelegate:)];
}

- (void)mockPoint:(GZLocation *)location {
    self.pointLocation = location;
}

- (void)pointMock {
    if (!self.pointLocation) { return; }
    [self dispatchLocationsToAll:@[self.pointLocation]];
}

- (void)dispatchLocationsToAll:(NSArray*)locations {
    for (NSString *key in instance.locationMonitor.keyEnumerator) {
        if ([key hasSuffix:@"_binder"]) {
            NSString *binderKey = key;
            CLLocationManager *binderManager = [instance.locationMonitor objectForKey:binderKey];
            [self dispatchLocationUpdate:binderManager locations:locations];
        }
    }
}

- (void)startMockPoint {
    instance.mocking = YES;
    if (!_simTimer) {
        _weakProxy = [GZWeakProxy alloc];
        _weakProxy.target = self;
        self.simTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self.weakProxy selector:@selector(pointMock) userInfo:nil repeats:YES];
        [self.simTimer fire];
    }
}

- (void)stopMockPoint{
    instance.mocking = NO;
    if(self.simTimer) {
        [self.simTimer invalidate];
        self.simTimer = nil;
    }
}

//if manager is nil.enum all manager.
-(void)enumDelegate:(CLLocationManager*)manager block:(void (^)(id<CLLocationManagerDelegate> delegate))block{
    NSString *key = [NSString stringWithFormat:@"%p_delegate",manager];
    id<CLLocationManagerDelegate> delegate = [instance.locationMonitor objectForKey:key];
    if (delegate) {
        block(delegate);
    }
}

#pragma mark - CLLocationManagerDelegate

/*
 *  locationManager:didUpdateToLocation:fromLocation:
 *
 *  Discussion:
 *    Invoked when a new location is available. oldLocation may be nil if there is no previous location
 *    available.
 *
 *    This method is deprecated. If locationManager:didUpdateLocations: is
 *    implemented, this method will not be called.
 */
- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation API_AVAILABLE(macos(10.6)) API_DEPRECATED("Implement -locationManager:didUpdateLocations: instead", ios(2.0, 6.0)) API_UNAVAILABLE(watchos, tvos) {
    if (instance.isMocking) {
        NSLog(@"模拟导航中，不处理%s系统逻辑",__func__);
        return;
    }
    [self enumDelegate:manager block:^(id<CLLocationManagerDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [delegate locationManager:manager didUpdateToLocation:newLocation fromLocation:oldLocation];
#pragma clang diagnostic pop
        }
    }];
}

/*
 *  locationManager:didUpdateLocations:
 *
 *  Discussion:
 *    Invoked when new locations are available.  Required for delivery of
 *    deferred locations.  If implemented, updates will
 *    not be delivered to locationManager:didUpdateToLocation:fromLocation:
 *
 *    locations is an array of CLLocation objects in chronological order.
 */
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray<CLLocation *> *)locations API_AVAILABLE(ios(6.0), macos(10.9)) {
    if (instance.isMocking) {
        NSLog(@"模拟轨迹中，不处理系统定位更新逻辑");
        return;
    }
    [self enumDelegate:manager block:^(id<CLLocationManagerDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
            [delegate locationManager:manager didUpdateLocations:locations];
        }
    }];
}

/*
 *  locationManager:didUpdateHeading:
 *
 *  Discussion:
 *    Invoked when a new heading is available.
 */
- (void)locationManager:(CLLocationManager *)manager
       didUpdateHeading:(CLHeading *)newHeading API_AVAILABLE(ios(3.0), macos(10.15), watchos(2.0)) API_UNAVAILABLE(tvos) {
    if (instance.isMocking) {
        NSLog(@"模拟导航中，不处理%s系统逻辑",__func__);
        return;
    }
    [self enumDelegate:manager block:^(id<CLLocationManagerDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(locationManager:didUpdateHeading:)]) {
            [delegate locationManager:manager didUpdateHeading:newHeading];
        }
    }];
}

/*
 *  locationManagerShouldDisplayHeadingCalibration:
 *
 *  Discussion:
 *    Invoked when a new heading is available. Return YES to display heading calibration info. The display
 *    will remain until heading is calibrated, unless dismissed early via dismissHeadingCalibrationDisplay.
 */
- (BOOL)locationManagerShouldDisplayHeadingCalibration:(CLLocationManager *)manager  API_AVAILABLE(ios(3.0), macos(10.15), watchos(2.0)) API_UNAVAILABLE(tvos) {
    return YES;
}

/*
 *  locationManager:didDetermineState:forRegion:
 *
 *  Discussion:
 *    Invoked when there's a state transition for a monitored region or in response to a request for state via a
 *    a call to requestStateForRegion:.
 */
- (void)locationManager:(CLLocationManager *)manager
      didDetermineState:(CLRegionState)state forRegion:(CLRegion *)region API_AVAILABLE(ios(7.0), macos(10.10)) API_UNAVAILABLE(watchos, tvos) {
    [self enumDelegate:manager block:^(id<CLLocationManagerDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(locationManager:didDetermineState:forRegion:)]) {
            [delegate locationManager:manager didDetermineState:state forRegion:region];
        }
    }];
}

/*
 *  locationManager:didRangeBeacons:inRegion:
 *
 *  Discussion:
 *    Invoked when a new set of beacons are available in the specified region.
 *    beacons is an array of CLBeacon objects.
 *    If beacons is empty, it may be assumed no beacons that match the specified region are nearby.
 *    Similarly if a specific beacon no longer appears in beacons, it may be assumed the beacon is no longer received
 *    by the device.
 */
- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray<CLBeacon *> *)beacons
               inRegion:(CLBeaconRegion *)region API_DEPRECATED_WITH_REPLACEMENT("Use locationManager:didRangeBeacons:satisfyingConstraint:", ios(7.0, 13.0), macos(10.15, 10.15)) API_UNAVAILABLE(watchos, tvos) {
    [self enumDelegate:manager block:^(id<CLLocationManagerDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(locationManager:didRangeBeacons:inRegion:)]) {
            [delegate locationManager:manager didRangeBeacons:beacons inRegion:region];
        }
    }];
}

/*
 *  locationManager:rangingBeaconsDidFailForRegion:withError:
 *
 *  Discussion:
 *    Invoked when an error has occurred ranging beacons in a region. Error types are defined in "CLError.h".
 */
- (void)locationManager:(CLLocationManager *)manager
rangingBeaconsDidFailForRegion:(CLBeaconRegion *)region
              withError:(NSError *)error API_DEPRECATED_WITH_REPLACEMENT("Use locationManager:didFailRangingBeaconsForConstraint:error:", ios(7.0, 13.0), macos(10.15, 10.15)) API_UNAVAILABLE(watchos, tvos) {
    [self enumDelegate:manager block:^(id<CLLocationManagerDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(locationManager:rangingBeaconsDidFailForRegion:withError:)]) {
            [delegate locationManager:manager rangingBeaconsDidFailForRegion:region withError:error];
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager
        didRangeBeacons:(NSArray<CLBeacon *> *)beacons
   satisfyingConstraint:(CLBeaconIdentityConstraint *)beaconConstraint API_AVAILABLE(ios(13.0), macos(10.15)) API_UNAVAILABLE(watchos, tvos) {
    [self enumDelegate:manager block:^(id<CLLocationManagerDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(locationManager:didRangeBeacons:satisfyingConstraint:)]) {
            [delegate locationManager:manager didRangeBeacons:beacons satisfyingConstraint:beaconConstraint];
        }
    }];
}

- (void)locationManager:(CLLocationManager *)manager
didFailRangingBeaconsForConstraint:(CLBeaconIdentityConstraint *)beaconConstraint
                  error:(NSError *)error API_AVAILABLE(ios(13.0), macos(10.15)) API_UNAVAILABLE(watchos, tvos) {
    [self enumDelegate:manager block:^(id<CLLocationManagerDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(locationManager:didFailRangingBeaconsForConstraint:error:)]) {
            [delegate locationManager:manager didFailRangingBeaconsForConstraint:beaconConstraint error:error];
        }
    }];
}

/*
 *  locationManager:didEnterRegion:
 *
 *  Discussion:
 *    Invoked when the user enters a monitored region.  This callback will be invoked for every allocated
 *    CLLocationManager instance with a non-nil delegate that implements this method.
 */
- (void)locationManager:(CLLocationManager *)manager
         didEnterRegion:(CLRegion *)region API_AVAILABLE(ios(4.0), macos(10.8)) API_UNAVAILABLE(watchos, tvos) {
    [self enumDelegate:manager block:^(id<CLLocationManagerDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(locationManager:didEnterRegion:)]) {
            [delegate locationManager:manager didEnterRegion:region];
        }
    }];
}

/*
 *  locationManager:didExitRegion:
 *
 *  Discussion:
 *    Invoked when the user exits a monitored region.  This callback will be invoked for every allocated
 *    CLLocationManager instance with a non-nil delegate that implements this method.
 */
- (void)locationManager:(CLLocationManager *)manager
          didExitRegion:(CLRegion *)region API_AVAILABLE(ios(4.0), macos(10.8)) API_UNAVAILABLE(watchos, tvos) {
    [self enumDelegate:manager block:^(id<CLLocationManagerDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(locationManager:didExitRegion:)]) {
            [delegate locationManager:manager didExitRegion:region];
        }
    }];
}

/*
 *  locationManager:didFailWithError:
 *
 *  Discussion:
 *    Invoked when an error has occurred. Error types are defined in "CLError.h".
 */
- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error {
    [self enumDelegate:manager block:^(id<CLLocationManagerDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(locationManager:didFailWithError:)]) {
            [delegate locationManager:manager didFailWithError:error];
        }
    }];
}

/*
 *  locationManager:monitoringDidFailForRegion:withError:
 *
 *  Discussion:
 *    Invoked when a region monitoring error has occurred. Error types are defined in "CLError.h".
 */
- (void)locationManager:(CLLocationManager *)manager
monitoringDidFailForRegion:(nullable CLRegion *)region
              withError:(NSError *)error API_AVAILABLE(ios(4.0), macos(10.8)) API_UNAVAILABLE(watchos, tvos) {
    [self enumDelegate:manager block:^(id<CLLocationManagerDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(locationManager:monitoringDidFailForRegion:withError:)]) {
            [delegate locationManager:manager monitoringDidFailForRegion:region withError:error];
        }
    }];
}

/*
 *  locationManager:didChangeAuthorizationStatus:
 *
 *  Discussion:
 *    Invoked when the authorization status changes for this application.
 */
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status API_DEPRECATED_WITH_REPLACEMENT("-locationManagerDidChangeAuthorization:", ios(4.2, 14.0), macos(10.7, 11.0), watchos(1.0, 7.0), tvos(9.0, 14.0)) {
    [self enumDelegate:manager block:^(id<CLLocationManagerDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(locationManager:didChangeAuthorizationStatus:)]) {
            [delegate locationManager:manager didChangeAuthorizationStatus:status];
        }
    }];
}

/*
 *  locationManagerDidChangeAuthorization:
 *
 *  Discussion:
 *    Invoked when either the authorizationStatus or
 *    accuracyAuthorization properties change
 */
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager API_AVAILABLE(ios(14.0), macos(11.0), watchos(7.0), tvos(14.0)) {
    [self enumDelegate:manager block:^(id<CLLocationManagerDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(locationManagerDidChangeAuthorization:)]) {
            [delegate locationManagerDidChangeAuthorization:manager];
        }
    }];
}

/*
 *  locationManager:didStartMonitoringForRegion:
 *
 *  Discussion:
 *    Invoked when a monitoring for a region started successfully.
 */
- (void)locationManager:(CLLocationManager *)manager
didStartMonitoringForRegion:(CLRegion *)region API_AVAILABLE(ios(5.0), macos(10.8)) API_UNAVAILABLE(watchos, tvos) {
    [self enumDelegate:manager block:^(id<CLLocationManagerDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(locationManager:didStartMonitoringForRegion:)]) {
            [delegate locationManager:manager didStartMonitoringForRegion:region];
        }
    }];
}

/*
 *  Discussion:
 *    Invoked when location updates are automatically paused.
 */
- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager API_AVAILABLE(ios(6.0), macos(10.15)) API_UNAVAILABLE(watchos, tvos) {
    [self enumDelegate:manager block:^(id<CLLocationManagerDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(locationManagerDidPauseLocationUpdates:)]) {
            [delegate locationManagerDidPauseLocationUpdates:manager];
        }
    }];
}

/*
 *  Discussion:
 *    Invoked when location updates are automatically resumed.
 *
 *    In the event that your application is terminated while suspended, you will
 *      not receive this notification.
 */
- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager API_AVAILABLE(ios(6.0), macos(10.15)) API_UNAVAILABLE(watchos, tvos) {
    [self enumDelegate:manager block:^(id<CLLocationManagerDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(locationManagerDidResumeLocationUpdates:)]) {
            [delegate locationManagerDidResumeLocationUpdates:manager];
        }
    }];
}

/*
 *  locationManager:didFinishDeferredUpdatesWithError:
 *
 *  Discussion:
 *    Invoked when deferred updates will no longer be delivered. Stopping
 *    location, disallowing deferred updates, and meeting a specified criterion
 *    are all possible reasons for finishing deferred updates.
 *
 *    An error will be returned if deferred updates end before the specified
 *    criteria are met (see CLError), otherwise error will be nil.
 */
- (void)locationManager:(CLLocationManager *)manager
didFinishDeferredUpdatesWithError:(nullable NSError *)error API_AVAILABLE(ios(6.0), macos(10.9)) API_UNAVAILABLE(watchos, tvos) {
    [self enumDelegate:manager block:^(id<CLLocationManagerDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(locationManager:didFinishDeferredUpdatesWithError:)]) {
            [delegate locationManager:manager didFinishDeferredUpdatesWithError:error];
        }
    }];
}

/*
 *  locationManager:didVisit:
 *
 *  Discussion:
 *    Invoked when the CLLocationManager determines that the device has visited
 *    a location, if visit monitoring is currently started (possibly from a
 *    prior launch).
 */
- (void)locationManager:(CLLocationManager *)manager didVisit:(CLVisit *)visit API_AVAILABLE(ios(8.0), macos(10.15)) API_UNAVAILABLE(watchos, tvos) {
    [self enumDelegate:manager block:^(id<CLLocationManagerDelegate> delegate) {
        if ([delegate respondsToSelector:@selector(locationManager:didVisit:)]) {
            [delegate locationManager:manager didVisit:visit];
        }
    }];
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
-(void)dispatchLocationUpdate:(CLLocationManager *)manager locations:(NSArray <GZLocation *>*)locations {
    if (!locations || (locations && [locations count] <=0)) { return; }
    GZLocation *locationTemp = [locations firstObject];
    
    CLLocation *location = nil;
    CLLocationCoordinate2D cor2D = CLLocationCoordinate2DMake(locationTemp.coordinate.latitude, locationTemp.coordinate.longitude);
    NSDate *locTime = [NSDate dateWithTimeIntervalSince1970:(locationTemp.timestamp / 1000)];
    if (@available(iOS 15.0, *)) {
        CLLocationSourceInformation *locSource = [[CLLocationSourceInformation alloc] initWithSoftwareSimulationState:locationTemp.sourceInformation.isSimulatedBySoftware andExternalAccessoryState:locationTemp.sourceInformation.isProducedByAccessory];
        location = [[CLLocation alloc] initWithCoordinate:cor2D altitude:locationTemp.altitude horizontalAccuracy:locationTemp.horizontalAccuracy verticalAccuracy:locationTemp.verticalAccuracy course:locationTemp.course courseAccuracy:locationTemp.courseAccuracy speed:locationTemp.speed speedAccuracy:locationTemp.speedAccuracy timestamp:locTime sourceInfo:locSource];
    } else if (@available(iOS 13.4, *)) {
        location = [[CLLocation alloc] initWithCoordinate:cor2D altitude:locationTemp.altitude horizontalAccuracy:locationTemp.horizontalAccuracy verticalAccuracy:locationTemp.verticalAccuracy course:locationTemp.course courseAccuracy:locationTemp.courseAccuracy speed:locationTemp.speed speedAccuracy:locationTemp.speedAccuracy timestamp:locTime];
    } else {
        location = [[CLLocation alloc] initWithCoordinate:cor2D altitude:locationTemp.altitude horizontalAccuracy:locationTemp.horizontalAccuracy verticalAccuracy:locationTemp.verticalAccuracy course:locationTemp.course speed:locationTemp.speed timestamp:locTime];
    }
    
    NSString *key = [NSString stringWithFormat:@"%p_delegate",manager];
    id<CLLocationManagerDelegate> delegate = [instance.locationMonitor objectForKey:key];
    if ([delegate respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
        [delegate locationManager:manager didUpdateLocations:@[location]];
    } else if ([delegate respondsToSelector:@selector(locationManager:didUpdateToLocation:fromLocation:)]){
        [delegate locationManager:manager didUpdateToLocation:locations.firstObject fromLocation:self.oldLocation];
        self.oldLocation = locations.firstObject;
    }
}
#pragma clang diagnostic pop
@end
