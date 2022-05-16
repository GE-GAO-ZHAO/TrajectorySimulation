//
//  GZWeakProxy.m
//  GZBusinessKit
//
//  Created by zfli on 2020/11/11.
//  Copyright © 2020 com.TrajectorySimulation.cn. All rights reserved.
//

#import "GZWeakProxy.h"

@implementation GZWeakProxy
// 重写方法签名，设置转发对象
- (NSMethodSignature *) methodSignatureForSelector:(SEL)sel{
    return [self.target methodSignatureForSelector:sel];
}

// 转发
-(void)forwardInvocation:(NSInvocation *)invocation{
    [invocation invokeWithTarget:self.target];
}

@end
