//
//  GZTrajectorySimulationMiddieware.h
//  front-mathcing-iOS
//
//  Created by 葛高召 on 2022/3/6.
//

#import <Foundation/Foundation.h>
#import "GZLocation.h"

NS_ASSUME_NONNULL_BEGIN

@interface GZTrajectorySimulationMiddieware : NSObject

+ (instancetype)shareInstance;
+ (instancetype)destory;

- (void)addLocationBinder:(id)binder delegate:(id)delegate;
- (void)mockPoint:(GZLocation *)location;
- (void)startMockPoint;
- (void)stopMockPoint;

@end

NS_ASSUME_NONNULL_END
