//
//  GGZViewController.m
//  TrajectorySimulation
//
//  Created by 葛高召 on 05/16/2022.
//  Copyright (c) 2022 葛高召. All rights reserved.
//

#import "GGZViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLGeocoder.h>

@interface GGZViewController ()<CLLocationManagerDelegate>

/// 系统gps定位管理者
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation GGZViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [self.locationManager startUpdatingLocation];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.    
}

#pragma mark --
#pragma mark -- CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    
}
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    CLLocation* location = [locations firstObject];
    NSLog(@"系统gps点回调>lon:%.6f,lat:%.6f",location.coordinate.longitude,location.coordinate.latitude);
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {

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
