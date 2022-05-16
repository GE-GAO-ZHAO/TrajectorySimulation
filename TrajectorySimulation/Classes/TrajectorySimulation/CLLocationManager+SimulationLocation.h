//
//  CLLocationManager+SimulationLocation.h
//  front-mathcing-iOS
//
//  Created by 葛高召 on 2022/1/17.
//

#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface CLLocationManager (SimulationLocation)

- (void)hll_swizzleLocationDelegate:(id)delegate;

@end

NS_ASSUME_NONNULL_END
