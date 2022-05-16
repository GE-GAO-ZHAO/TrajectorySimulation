//
//  GZTrajectorySimulationProtocol.h
//  front-mathcing-iOS
//
//  Created by 葛高召 on 2022/3/5.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

#define APPName [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]
#define gpsFolderPath [NSString stringWithFormat:@"%@/%@GPS录制",CacheFilePath,APPName]
#define gpsFilePath  [NSString stringWithFormat:@"%@/gps_record.txt",gpsFolderPath]

@protocol GZTrajectorySimulationProtocol <NSObject>


- (void)startRecordGPS;
- (void)stopRecordGPS;

- (void)playbackGpsWithFrequency:(NSInteger)frequency;
- (void)pause;
- (void)play;

- (void)stopPlaybackGps;

@end

NS_ASSUME_NONNULL_END
