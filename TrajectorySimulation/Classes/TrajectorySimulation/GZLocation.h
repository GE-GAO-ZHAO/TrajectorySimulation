//
//  GZLocation.h
//  front-mathcing-iOS
//
//  Created by 葛高召 on 2022/3/24.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
NS_ASSUME_NONNULL_BEGIN


@interface GZFloor : NSObject
@property(nonatomic , assign) NSInteger level;
@end

@interface GZLocationSourceInformation : NSObject
@property(nonatomic , assign) BOOL isSimulatedBySoftware;
@property(nonatomic , assign) BOOL isProducedByAccessory;
@end

@interface GZCoordinate : NSObject
@property(nonatomic , assign) double latitude;
@property(nonatomic , assign) double longitude;
@end


@interface GZLocation : NSObject

/*
 *  coordinate
 *
 *  Discussion:
 *    Returns the coordinate of the current location.
 */
@property(nonatomic , strong) GZCoordinate *coordinate; API_AVAILABLE(ios(8.0), macos(10.15));

/*
 *  altitude
 *
 *  Discussion:
 *    Returns the altitude of the location. Can be positive (above sea level) or negative (below sea level).
 */
@property(nonatomic , assign) double altitude;

/*
 *  ellipsoidalAltitude
 *
 *  Discussion:
 *    Returns the ellipsoidal altitude of the location under the WGS 84 reference frame.
 *    Can be positive or negative.
 */
@property(nonatomic, assign) double ellipsoidalAltitude API_AVAILABLE(ios(15), macos(12), watchos(8), tvos(15));

/*
 *  horizontalAccuracy
 *
 *  Discussion:
 *    Returns the horizontal accuracy of the location. Negative if the lateral location is invalid.
 */
@property(nonatomic, assign) double horizontalAccuracy;

/*
 *  verticalAccuracy
 *
 *  Discussion:
 *    Returns the vertical accuracy of the location. Negative if the altitude is invalid.
 */
@property(nonatomic, assign) double verticalAccuracy;

/*
 *  course
 *
 *  Discussion:
 *    Returns the course of the location in degrees true North. Negative if course is invalid.
 *
 *  Range:
 *    0.0 - 359.9 degrees, 0 being true North
 */
@property(nonatomic, assign) double course API_AVAILABLE(ios(2.2), macos(10.7));

/*
 *  courseAccuracy
 *
 *  Discussion:
 *    Returns the course accuracy of the location in degrees.  Returns negative if course is invalid.
 */
@property(nonatomic, assign) double courseAccuracy API_AVAILABLE(ios(13.4), macos(10.15.4), watchos(6.2), tvos(13.4));

/*
 *  speed
 *
 *  Discussion:
 *    Returns the speed of the location in m/s. Negative if speed is invalid.
 */
@property(nonatomic, assign) double speed API_AVAILABLE(ios(2.2), macos(10.7));

/*
 *  speedAccuracy
 *
 *  Discussion:
 *    Returns the speed accuracy of the location in m/s. Returns -1 if invalid.
 */
@property(nonatomic, assign) double speedAccuracy API_AVAILABLE(macos(10.15), ios(10.0), watchos(3.0), tvos(10.0));

/*
 *  timestamp
 *
 *  Discussion:
 *    Returns the timestamp when this location was determined.
 */
@property(nonatomic, assign) double timestamp;

/*
 *  floor
 *
 *  Discussion:
 *    Contains information about the logical floor that you are on
 *    in the current building if you are inside a supported venue.
 *    This will be nil if the floor is unavailable.
 */
@property(nonatomic, strong) GZFloor *floor API_AVAILABLE(ios(8.0), macos(10.15));

/*
 *  sourceInformation
 *
 *  Discussion:
 *    Contains information about the source of this location.
 */
@property(nonatomic, strong) GZLocationSourceInformation *sourceInformation API_AVAILABLE(ios(15.0), watchos(8.0), tvos(15.0), macos(12.0));


- (instancetype)initWith:(CLLocation *)location;

@end

NS_ASSUME_NONNULL_END
