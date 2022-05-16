//
//  GZTajectoryRecorder.h
//  front-mathcing-iOS
//
//  Created by 葛高召 on 2022/3/5.
//

#import <Foundation/Foundation.h>
#import "GZFileTool.h"
#import "GZGpsCollector.h"
#import <GZTrajectoryRecordProtocol.h>
NS_ASSUME_NONNULL_BEGIN

@interface GZTajectoryRecorder : NSObject <GZTrajectoryRecordProtocol,GZGpsCollectorProtocol>

@end

NS_ASSUME_NONNULL_END
