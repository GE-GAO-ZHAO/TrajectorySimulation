//
//  GZLocation.m
//  front-mathcing-iOS
//
//  Created by 葛高召 on 2022/3/24.
//

#import "GZLocation.h"


@implementation GZCoordinate

@end

@implementation GZFloor
@end

@implementation GZLocationSourceInformation
@end

@implementation GZLocation

- (instancetype)initWith:(CLLocation *)location {
    if (self = [super init]) {
        _coordinate = [[GZCoordinate alloc] init];
        _coordinate.latitude = location.coordinate.latitude;
        _coordinate.longitude = location.coordinate.longitude;
        
        _altitude = location.altitude;
        if (@available(iOS 15.0, *)) {
            _ellipsoidalAltitude = location.ellipsoidalAltitude;;
        } else {
            _ellipsoidalAltitude = 0.f;
        }
        _horizontalAccuracy = location.horizontalAccuracy;
        _course = location.course;
        if (@available(iOS 13.4, *)) {
            _courseAccuracy = location.courseAccuracy;
        } else {
            _courseAccuracy = 0.f;
        }
        _speed = location.speed;
        if (@available(iOS 10.0, *)) {
            _speedAccuracy = (double)location.speedAccuracy;
        }
        _timestamp = ([location.timestamp timeIntervalSince1970]*1000);
        
        _floor = [[GZFloor alloc] init];
        _floor.level = location.floor.level;
        
        _sourceInformation = [[GZLocationSourceInformation alloc] init];
        if (@available(iOS 15.0, *)) {
            _sourceInformation.isSimulatedBySoftware = location.sourceInformation.isSimulatedBySoftware;
            _sourceInformation.isProducedByAccessory = location.sourceInformation.isProducedByAccessory;
        } else {
            _sourceInformation = [[GZLocationSourceInformation alloc] init];
        }
    }
    return self;
}

@end
