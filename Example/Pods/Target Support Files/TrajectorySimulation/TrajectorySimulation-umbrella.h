#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "HLLWeakProxy.h"
#import "NSObject+HLLMKYYModel.h"
#import "NSObject+MethodSwizzle.h"
#import "UIView+NaviSimulation.h"
#import "HLLDateTool.h"
#import "HLLFileTool.h"
#import "CLLocationManager+SimulationLocation.h"
#import "HLLGpsCollector.h"
#import "HLLLocation.h"
#import "HLLSimulateNaviVC.h"
#import "HLLTajectoryRecorder.h"
#import "HLLTrajectoryBackPlayer.h"
#import "HLLTrajectoryBackPlayerProtocol.h"
#import "HLLTrajectoryPlaybackManager.h"
#import "HLLTrajectoryRecordProtocol.h"
#import "HLLTrajectorySimulationMiddieware.h"
#import "HLLTrajectorySimulationProtocol.h"

FOUNDATION_EXPORT double TrajectorySimulationVersionNumber;
FOUNDATION_EXPORT const unsigned char TrajectorySimulationVersionString[];

