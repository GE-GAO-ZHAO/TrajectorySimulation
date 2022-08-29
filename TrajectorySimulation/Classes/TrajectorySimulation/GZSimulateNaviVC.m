//
//  GZSimulateNaviVC.m
//  front-mathcing-iOS
//
//  Created by 葛高召 on 2022/3/23.
//

#import "GZSimulateNaviVC.h"
#import "GZTrajectoryPlaybackManager.h"

@interface GZSimulateNaviVC ()

@property (nonatomic, strong) UIStackView *toolsStackView;

@end

@implementation GZSimulateNaviVC

#pragma mark --
#pragma mark -- life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupUI];
}

- (void)dealloc {
    NSLog(@"==== HLLSimulateNaviVC dealloc ====");
}

#pragma mark --
#pragma mark -- private

- (void)setupUI {
    //添加撤销
    UIButton *backBtn = [self createBtnWithTitle:@"返回" tag:1000];
    backBtn.frame = CGRectMake(5, 50, 50, 30);
    [backBtn addTarget:self action:@selector(backBthClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    //添加工具
    NSArray *btnTitles = @[@"开启GPS录制",@"关闭GPS录制",@"开启GPS回放",@"关闭GPS回放"];
    for (int i=0;i<4;++i) {
        [self.toolsStackView addArrangedSubview:[self createBtnWithTitle:btnTitles[i] tag:i]];
    }
    [self.view addSubview:self.toolsStackView];
}

- (UIButton *)createBtnWithTitle:(NSString *)titleName tag:(int)tag{
    UIButton *btn = [[UIButton alloc] init];
    btn.tag = tag;
    [btn setTitle:titleName forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(buttonClickedWith:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn setBackgroundColor:[self randomColor]];
    return btn;
}

- (UIColor *)randomColor {
    int R = (arc4random() % 256) ;
    int G = (arc4random() % 256) ;
    int B = (arc4random() % 256) ;
    return [UIColor colorWithRed:R/255.0 green:G/255.0 blue:B/255.0 alpha:1];
}

- (void)backBthClicked:(UIButton *)sender {
    [self dismissVC];
}

- (void)dismissVC {
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSUserDefaults standardUserDefaults] setValue:@"0" forKey:@"simulateNaviDisplay"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }];
}

- (void)buttonClickedWith:(UIButton *)sender {
    switch (sender.tag) {
        case 0:
        {
            [[GZTrajectoryPlaybackManager sharedInstance] startRecordGPSWithComplate:^(BOOL sucess, NSString * _Nonnull msg) {
                if (!sucess && msg && [msg length] >0) {
                    [self waringTipWithTipText:msg];
                } else {
                    [self dismissVC];
                }
            }];
        }
            break;
        case 1:
        {
            [[GZTrajectoryPlaybackManager sharedInstance] stopRecordGPSWithComplate:^(BOOL sucess, NSString * _Nonnull msg) {
                if (!sucess && msg && [msg length] >0) {
                    [self waringTipWithTipText:msg];
                } else {
                    [self dismissVC];
                }
            }];
        }
            break;
        case 2:
        {
            [[GZTrajectoryPlaybackManager sharedInstance] playbackGpsWithComplate:^(BOOL sucess, NSString * _Nonnull msg) {
                if (!sucess && msg && [msg length] >0) {
                    [self waringTipWithTipText:msg];
                } else {
                    [self dismissVC];
                }
            }];
        }
            break;
        case 3:
        {
            [[GZTrajectoryPlaybackManager sharedInstance] stopPlaybackGpsWithComplate:^(BOOL sucess, NSString * _Nonnull msg) {
                if (!sucess && msg && [msg length] >0) {
                    [self waringTipWithTipText:msg];
                } else {
                    [self dismissVC];
                }
            }];
        }
            break;
    }
}

- (void)waringTipWithTipText:(NSString *)tipText {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"操作失败"
                                                                   message:tipText
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *overNavi = [UIAlertAction actionWithTitle:@"确认"
                                                       style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
    }];
    [alert addAction:overNavi];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark --
#pragma mark -- getter

- (UIStackView *)toolsStackView {
    if (!_toolsStackView) {
        _toolsStackView = [[UIStackView alloc] initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width - 300) /2, 88, 300, [UIScreen mainScreen].bounds.size.height - 88)];
        _toolsStackView.axis = UILayoutConstraintAxisVertical ;
        _toolsStackView.alignment = UIStackViewAlignmentFill;
        _toolsStackView.distribution = UIStackViewDistributionFillEqually;
        _toolsStackView.spacing = 10.f;
    }
    return _toolsStackView;
}

@end
