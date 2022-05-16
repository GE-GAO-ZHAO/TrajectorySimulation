//
//  GZWeakProxy.h
//  GZBusinessKit
//
//  Created by zfli on 2020/11/11.
//  Copyright © 2020 com.TrajectorySimulation.cn. All rights reserved.
//

#import <Foundation/Foundation.h>
@interface GZWeakProxy : NSProxy
@property (nonatomic,weak) id target;
@end
