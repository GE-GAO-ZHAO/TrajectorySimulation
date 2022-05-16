//
//  CLLocationManager+SimulationLocation.m
//  front-mathcing-iOS
//
//  Created by 葛高召 on 2022/1/17.
//

#import "CLLocationManager+SimulationLocation.h"
#import "GZTrajectorySimulationMiddieware.h"
#import <objc/runtime.h>

@implementation CLLocationManager (SimulationLocation)


- (void)hll_swizzleLocationDelegate:(id)delegate {
    if (delegate) {
        [self hll_swizzleLocationDelegate:[GZTrajectorySimulationMiddieware shareInstance]];
        [[GZTrajectorySimulationMiddieware shareInstance] addLocationBinder:self delegate:delegate];
        Protocol *proto = objc_getProtocol("CLLocationManagerDelegate");
        unsigned int count;
        struct objc_method_description *methods = protocol_copyMethodDescriptionList(proto, NO, YES, &count);
        for(unsigned i = 0; i < count; i++) {
            SEL sel = methods[i].name;
            if ([delegate respondsToSelector:sel]) {
                if (![[GZTrajectorySimulationMiddieware shareInstance] respondsToSelector:sel]) {
                    NSAssert(NO, @"Delegate : %@ not implementation SEL : %@",delegate,NSStringFromSelector(sel));
                }
            }
        }
        free(methods);
        
    } else {
        [self hll_swizzleLocationDelegate:delegate];
    }
}

@end
