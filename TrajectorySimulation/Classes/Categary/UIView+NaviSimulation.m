//
//  UIView+NaviSimulation.m
//  front-mathcing-iOS
//
//  Created by 葛高召 on 2022/4/21.
//

#import "UIView+NaviSimulation.h"
#import "GZSimulateNaviVC.h"
@implementation UIView (NaviSimulation)

#ifdef DEBUG
//摇一摇进入开发测试页面
- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event{
    [self select];
}
#endif

- (UIWindow *)getKeyWindow{
    UIWindow *keyWindow = nil;
    if ([[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        keyWindow = [[UIApplication sharedApplication].delegate window];
    } else {
        NSArray *windows = [UIApplication sharedApplication].windows;
        for (UIWindow *window in windows) {
            if (!window.hidden) {
                keyWindow = window;
                break;
            }
        }
    }
    return keyWindow;
}

- (UIViewController *)topViewControllerForKeyWindow {
    UIViewController *resultVC;
    UIWindow *keyWindow = [self getKeyWindow];
    resultVC = [self _topViewController:[keyWindow rootViewController]];
    while (resultVC.presentedViewController) {
        resultVC = [self _topViewController:resultVC.presentedViewController];
    }
    return resultVC;
}

- (UIViewController *)_topViewController:(UIViewController *)vc {
    if ([vc isKindOfClass:[UINavigationController class]]) {
        return [self _topViewController:[(UINavigationController *)vc topViewController]];
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        return [self _topViewController:[(UITabBarController *)vc selectedViewController]];
    } else {
        return vc;
    }
    return nil;
}

- (void)select {
    BOOL res = [[[NSUserDefaults standardUserDefaults] valueForKey:@"simulateNaviDisplay"] boolValue];
    if (res) { return; }
    UIViewController *topVC = [self topViewControllerForKeyWindow];
    if (topVC) {
        [[NSUserDefaults standardUserDefaults] setValue:@"1" forKey:@"simulateNaviDisplay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        GZSimulateNaviVC *simulateNaviVC  = [[GZSimulateNaviVC alloc] init];
        simulateNaviVC.modalPresentationStyle = UIModalPresentationFullScreen;
        simulateNaviVC.edgesForExtendedLayout = YES;
        [topVC presentViewController:simulateNaviVC animated:YES completion:nil];
    }
}


@end
