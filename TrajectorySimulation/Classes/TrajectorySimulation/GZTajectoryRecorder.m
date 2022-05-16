//
//  GZTajectoryRecorder.m
//  front-mathcing-iOS
//
//  Created by 葛高召 on 2022/3/5.
//

#import "GZTajectoryRecorder.h"
#import "GZLocation.h"
#import "NSObject+GZYYModel.h"


@implementation GZTajectoryRecorder

#pragma mark --
#pragma mark -- life

- (void)startRecordGPS {
    [self createNewGPSFile];
    if (![[GZGpsCollector sharedInstance] locationEnabled])
    { [[GZGpsCollector sharedInstance] startLocationService]; }
    [[GZGpsCollector sharedInstance] addLocationListener:self];
}

- (void)stopRecordGPS {
    [[GZGpsCollector sharedInstance] removeLocationListener:self];
    [GZGpsCollector destory];
}

#pragma mark --
#pragma mark -- GPS变化

- (void)locationUpdateSuccessWith:(CLLocation *)location {
    NSLog(@"Business:gps录制 Event:gps回调信息 [lon:%6f,lat:%6f]",location.coordinate.longitude , location.coordinate.latitude);
    if (CLLocationCoordinate2DIsValid(location.coordinate)) {
        GZLocation *hllLocation = [[GZLocation alloc] initWith:location];
        NSString *gpsInfo = [hllLocation GZYY_modelToJSONString];
        [self writeWithContent:gpsInfo];
    } else {
        NSLog(@"Business:gps录制 Event:gps回调信息不处理 原因: 匹配点已达到终点或者经纬度信息异常");
    }
}

#pragma mark --
#pragma mark -- file methods

- (void)createNewGPSFile {
    [self deleteOldGpsFile];
    BOOL res = [[GZFileTool shareInstence] createFolderWithFolderPath:gpsFolderPath];
    if (!res) {
        NSLog(@"Business:gps录制 Event:创建gps记录文件夹失败，日志所在文件夹失败");
        return;
    }
    BOOL exist = [[GZFileTool shareInstence] fileExistsAtPath:gpsFilePath];
    if (!exist) {
        BOOL res = [[GZFileTool shareInstence] createFileWithFilePath:gpsFilePath];
        if (!res) {
            NSLog(@"Business:gps录制 Event:创建gps记录文件失败，日志文件创建失败");
            return;
        }
    }
}

- (void)deleteOldGpsFile {
    BOOL exist = [[GZFileTool shareInstence] fileExistsAtPath:gpsFilePath];
    if (exist) {
        [[GZFileTool shareInstence] deleteDerectorAtPath:gpsFilePath];
    }
}

- (void)writeWithContent:(NSString *)content {
    if (!content || [content length] <= 0) {
        NSLog(@"Business:gps录制 content not allowed to be empty");
        return;
    }
    content = [NSString stringWithFormat:@"%@!FF",content];
    [[GZFileTool shareInstence] writeDataWithData:content filePath:gpsFilePath];
}

@end
